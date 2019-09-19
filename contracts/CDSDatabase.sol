pragma solidity ^0.4.19;

import "./PermissionGroups.sol";
import "./OracleInterface.sol";
import "./RateInterface.sol";
import "./TST20Interface.sol";
import "./SafeMath.sol";

contract CDSDatabase is PermissionGroups {
    using SafeMath for uint;

    Oracle public CUSD2TTC;         //  n TTC / 1CUSD
    Oracle public CCNY2TTC;         //  n TTC / 1CCNY
    Oracle public CKRW2TTC;         //  n TTC / 1CKRW
    Oracle public CLAY2TTC;         //  n TTC / 1CLAY
    
    DC public TTCGainRate;          // n TTC / 1TTC, for TTC collateral by user
    DC public CLAYGainRate;         // n CLAY / 1CLAY, for CLAY collateral by user
    DC public reserveGainRate;      // n TTC / 1CLAY, for CLAY collateral by user
    DC public serviceFeeRate;       // n TTC / 1TTC 
    
    uint public debtTotal;          // BY TTC
    uint public debtCUSD;           // By CUSD
    uint public debtCCNY;           // BY CCNY
    uint public debtCKRW;           // BY CKRW
    
    struct GenerateInfo {
        uint CUSDAmounts;
        uint CCNYAmounts;
        uint CKRWAmounts;
        uint preServiceFee;         // By CLAY
        uint generateTime;          // timestamp
    }
    struct CollateralInfo {
        uint TTCAmounts;
        uint CLAYAmounts;
        uint TTCTime;
        uint CLAYTime;
    }
    mapping(address => CollateralInfo) public collateral;
    mapping(address => GenerateInfo) public generate;

    uint public constant SECONDS_PER_DAY = 86400;
    uint public constant BASE_DECIMAL = 6;
    uint public constant BASE_PERCENT = 10**BASE_DECIMAL; // 1000,000 , make sure the Oracle and DC use the same
    uint public initalCollateralRate = 5*10**(BASE_DECIMAL - 1);


    /* initialize address settings*/
    function initAddressSettings(uint _type,address _addr) onlyOperator public {
        require(_addr != address(0));
        if (_type == 1) {
            CUSD2TTC = Oracle(_addr);       
        }else if (_type == 2 ) {
            CCNY2TTC = Oracle(_addr);       
        }else if (_type == 3) {
            CKRW2TTC = Oracle(_addr);     
        }else if (_type == 4) {
            CLAY2TTC = Oracle(_addr);    
        }else if (_type == 5) {
            TTCGainRate = DC(_addr);       
        }else if (_type == 6) {
            CLAYGainRate = DC(_addr);       
        }else if (_type == 7) {
            serviceFeeRate = DC(_addr);     
        }else if (_type == 8) {
            reserveGainRate = DC(_addr);    
        }
    }

    /*get gain value by TTC for TTC collateral by address */
    function getTTCGain(address _addr) public returns (uint){
        require(_addr != address(0));
        if(collateral[_addr].TTCTime > 0 && collateral[_addr].TTCAmounts > 0 && _addr != address(0)){
            uint startTime = collateral[_addr].TTCTime.add(SECONDS_PER_DAY.mul(2));
            uint gainRate = 0;
            if (now > startTime) {
                gainRate = TTCGainRate.getValue(startTime,now);
            }
            return collateral[_addr].TTCAmounts.mul(gainRate).div(BASE_PERCENT);
        } else {
            return 0;
        }
    }
    
    /*get gain value for CLAY collateral by address, the gain contain CLAY from service feed & TTC from reserve vote reward */
    function getCLAYGain(address _addr) public returns (uint,uint){
        require(_addr != address(0));
        if(collateral[_addr].CLAYTime > 0 && collateral[_addr].CLAYAmounts > 0 && collateral[_addr].TTCTime > 0 && collateral[_addr].TTCAmounts > 0 && _addr != address(0)){
            uint startTime = collateral[_addr].CLAYTime.add(SECONDS_PER_DAY.mul(2));
            uint gainRate = 0;
            uint reserveVoteGainRate = 0;
            if(now > startTime) {
                gainRate = CLAYGainRate.getValue(startTime,now);
                reserveVoteGainRate = reserveGainRate.getValue(startTime,now);
            }
            uint CLAYGain = collateral[_addr].CLAYAmounts.mul(gainRate).div(BASE_PERCENT);
            uint reserveVoteGain = collateral[_addr].CLAYAmounts.mul(reserveVoteGainRate).div(BASE_PERCENT);
            return (CLAYGain,reserveVoteGain);
        } else {
            return (0,0);
        }
    }
    
    /*get total service fee by CLAY by address */
    function getServiceFee(address _addr) public returns (uint){
        require(_addr != address(0));
        uint startTime = generate[_addr].generateTime.add(SECONDS_PER_DAY);
        uint currentserviceFeeRate =0 ;
        if (now < startTime) {
            return generate[_addr].preServiceFee;
        }
        currentserviceFeeRate = serviceFeeRate.getValue(startTime,now);
        // cal all stable token to TTC
        uint totalGenerateValue = getCFIATByTTC(generate[_addr].CUSDAmounts,generate[_addr].CCNYAmounts,generate[_addr].CKRWAmounts);
        // cal service Fee TTC => CLAY
        return totalGenerateValue.mul(currentserviceFeeRate).div(CLAY2TTC.getLatestValue()).add(generate[_addr].preServiceFee);
    }
    
    /*cal CFIAT value To TTC */
    function getCFIATByTTC(uint _CUSDAmounts,uint _CCNYAmounts,uint _CKRWAmounts) public view returns(uint) {
        uint RateCUSD2TTC = 0;
        if (_CUSDAmounts > 0) {RateCUSD2TTC = CUSD2TTC.getLatestValue();}
        uint RateCCNY2TTC = 0;
        if (_CCNYAmounts > 0) {RateCCNY2TTC = CCNY2TTC.getLatestValue();}
        uint RateCKRW2TTC = 0;
        if (_CKRWAmounts > 0) {RateCKRW2TTC = CKRW2TTC.getLatestValue();}
        return _CUSDAmounts.mul(RateCUSD2TTC).add(_CCNYAmounts.mul(RateCCNY2TTC)).add(_CKRWAmounts.mul(RateCKRW2TTC)).div(BASE_PERCENT);
    }

    /*get withdrawable value ,By TTC,or By CLAY,and serviceFee */
    function getWithdrawable(address _addr) public returns(uint,uint,uint) {
        require(_addr != address(0));
        uint RateCLAY2TTC = CLAY2TTC.getLatestValue();
        uint serviceFee = getServiceFee(_addr);
        uint serviceFee2TTC = serviceFee.mul(RateCLAY2TTC).div(BASE_PERCENT);
        uint generatedValue = getCFIATByTTC(generate[_addr].CUSDAmounts,generate[_addr].CCNYAmounts,generate[_addr].CKRWAmounts);
        uint limitValue = getCollateralByTTC(_addr).mul(initalCollateralRate).div(BASE_PERCENT);
        uint withdrawableByTTC = 0;
        uint withdrawableByCLAY = 0;
        if (limitValue > generatedValue.add(serviceFee2TTC) ){
            withdrawableByTTC = limitValue.sub(generatedValue.add(serviceFee2TTC)).div(initalCollateralRate).mul(BASE_PERCENT);
            withdrawableByCLAY = withdrawableByTTC.div(RateCLAY2TTC).mul(BASE_PERCENT);
        }
        return (withdrawableByTTC,withdrawableByCLAY,serviceFee);
    }
    
    
    function getTTCCollateralInfo(address _addr) public view returns(uint,uint) {
        require(_addr != address(0));
        return (collateral[_addr].TTCAmounts,collateral[_addr].TTCTime);
    }

    function getCLAYCollateralInfo(address _addr) public view returns(uint,uint) {
        require(_addr != address(0));
        return (collateral[_addr].CLAYAmounts,collateral[_addr].CLAYTime);
    } 
    
    /* set collateralInfo For TTC */
    function setTTCCollateralInfo (address _addr, uint _TTCAmounts) public onlyOperator {
        require(_addr != address(0));
        CollateralInfo storage collateralInfo = collateral[_addr];
        collateralInfo.TTCAmounts = _TTCAmounts;
        if (_TTCAmounts == 0){
            collateralInfo.TTCTime = 0;
        }else{
            collateralInfo.TTCTime = now;
        } 
    }
    
    /* set collateralInfo For CLAY */
    function setCLAYCollateralInfo (address _addr, uint _CLAYAmounts) public onlyOperator {
        require(_addr != address(0));
        CollateralInfo storage collateralInfo = collateral[_addr];
        collateralInfo.CLAYAmounts = _CLAYAmounts;
        if (_CLAYAmounts == 0){
            collateralInfo.CLAYTime = 0;
        }else{
            collateralInfo.CLAYTime = now;
        }
    }
    
    function getGenerateInfo(address _addr) public view returns (uint,uint,uint,uint) {
        require(_addr != address(0));     
        return (generate[_addr].CUSDAmounts,generate[_addr].CCNYAmounts,generate[_addr].CKRWAmounts,generate[_addr].preServiceFee);
    }
    
    /*set generateInfo */
    function setGenerateInfo(uint _type,address _addr,uint _amounts,uint _serviceFee) public onlyOperator {
        require(_addr != address(0));
        require(_type == 1 || _type == 2 || _type == 3);
        GenerateInfo storage  generateInfo = generate[_addr];
        if (_type == 1) {
            if (generateInfo.CUSDAmounts > _amounts){
                debtCUSD = debtCUSD.sub(generateInfo.CUSDAmounts.sub(_amounts));
            }else {
                debtCUSD = debtCUSD.add(_amounts.sub(generateInfo.CUSDAmounts));
            }
            generateInfo.CUSDAmounts = _amounts;
        }else if (_type == 2) {
            if (generateInfo.CCNYAmounts > _amounts){
                debtCCNY = debtCCNY.sub(generateInfo.CCNYAmounts.sub(_amounts));
            }else {
                debtCCNY = debtCCNY.add(_amounts.sub(generateInfo.CCNYAmounts));
            }
            generateInfo.CCNYAmounts = _amounts;
        }else if (_type == 3) {
            if (generateInfo.CKRWAmounts > _amounts){
                debtCKRW = debtCKRW.sub(generateInfo.CKRWAmounts.sub(_amounts));
            }else {
                debtCKRW = debtCKRW.add(_amounts.sub(generateInfo.CKRWAmounts));
            }
            generateInfo.CKRWAmounts = _amounts;
        }
        debtTotal = getCFIATByTTC(debtCUSD,debtCCNY,debtCKRW);
        generateInfo.preServiceFee = _serviceFee;
        generateInfo.generateTime = now;
    }
    
     /*get generate limit */
    function getGenerateLimit(uint _type, address _addr) public returns(uint,uint) {
        require(_addr != address(0));
        require(_type == 1 || _type == 2 || _type == 3);
        uint remainValueTTC;
        uint serviceFee;
        (remainValueTTC,,serviceFee) = getWithdrawable(_addr);
        uint rateCFIAT2TTC ;
        if (_type == 1) {
            rateCFIAT2TTC = CUSD2TTC.getLatestValue();
        }else if (_type == 2) {
            rateCFIAT2TTC = CCNY2TTC.getLatestValue();
        }else if (_type ==3 ) {
            rateCFIAT2TTC = CKRW2TTC.getLatestValue();
        }
        return (remainValueTTC.mul(initalCollateralRate).div(rateCFIAT2TTC),serviceFee);
        
    }
    
    /* cal return serviceFee*/
    function getReturnServiceFee(address _addr,uint _amounts,uint _type) public returns(uint,uint) {
        require(_addr != address(0));
        require(_amounts > 0 && (_type == 1 || _type == 2 || _type == 3));
        uint generatedValue = getCFIATByTTC(generate[_addr].CUSDAmounts,generate[_addr].CCNYAmounts,generate[_addr].CKRWAmounts);
        uint serviceFee = getServiceFee(_addr);
        uint needToReturnServiceFee;
        uint rateCFIAT2TTC ;
        if (_type == 1) {
            require(_amounts <= generate[_addr].CUSDAmounts);
            rateCFIAT2TTC = CUSD2TTC.getLatestValue();
        }else if (_type ==2) {
            require(_amounts <= generate[_addr].CCNYAmounts);
            rateCFIAT2TTC = CCNY2TTC.getLatestValue();
        }else if (_type == 3){
            require(_amounts <= generate[_addr].CKRWAmounts);
            rateCFIAT2TTC = CKRW2TTC.getLatestValue();
        }
        needToReturnServiceFee = _amounts.mul(rateCFIAT2TTC).div(BASE_PERCENT).mul(serviceFee).div(generatedValue);
        return (serviceFee,needToReturnServiceFee);
    }
    
    /* get addr collateral amounts (TTC,CLAY) */
    function getAddrTotalCollateral(address _addr) public view returns(uint,uint) {
        require(_addr != address(0));
        uint CLAYGain;
        uint reserveVoteGain ;
        (CLAYGain,reserveVoteGain) = getCLAYGain(_addr);
        uint TTCGain = getTTCGain(_addr);
        uint CLAYAmounts = collateral[_addr].CLAYAmounts.add(CLAYGain);
        uint TTCAmounts = collateral[_addr].TTCAmounts.add(reserveVoteGain).add(TTCGain);
        return (TTCAmounts,CLAYAmounts);
    }

    /* get addr collateral amounts by TTC */
    function getCollateralByTTC(address _addr) public view returns(uint) {
        require(_addr != address(0));
        uint rateCLAY2TTC = CLAY2TTC.getLatestValue();
        uint TTCAmounts;
        uint CLAYAmounts;
        (TTCAmounts,CLAYAmounts) = getAddrTotalCollateral(_addr);
        return CLAYAmounts.mul(rateCLAY2TTC).div(BASE_PERCENT).add(TTCAmounts);
    }

    /* get collateral rate by address*/
    function getCollateralRate(address _addr) public returns(uint,uint) {
        require(_addr != address(0));
        uint collateralValue = getCollateralByTTC(_addr);
        uint serviceFee = getServiceFee(_addr);
        uint serviceFee2TTC = serviceFee.mul(CLAY2TTC.getLatestValue()).div(BASE_PERCENT);
        uint generatedValue = getCFIATByTTC(generate[_addr].CUSDAmounts,generate[_addr].CCNYAmounts,generate[_addr].CKRWAmounts);
        uint collateralRate = generatedValue.add(serviceFee2TTC).mul(BASE_PERCENT).div(collateralValue);
        return (collateralRate,serviceFee);
    }
    
    /*delete acoount */
    function deleteAccount(address _addr) public onlyOperator {
        require(_addr != address(0));
        uint generateDValue = getCFIATByTTC(generate[_addr].CUSDAmounts,generate[_addr].CCNYAmounts,generate[_addr].CKRWAmounts);
        debtTotal = debtTotal.sub(generateDValue);
        if (generate[_addr].CUSDAmounts > 0) {
            debtCUSD = debtCUSD.sub(generate[_addr].CUSDAmounts);
        }
        if (generate[_addr].CCNYAmounts > 0) {
            debtCCNY = debtCCNY.sub(generate[_addr].CCNYAmounts);
        }
        if (generate[_addr].CKRWAmounts > 0) {
            debtCKRW = debtCKRW.sub(generate[_addr].CKRWAmounts);
        }
        delete collateral[_addr];
        delete generate[_addr];
    }
    
}
