pragma solidity ^0.4.19;

import "./PermissionGroups.sol";
import "./CFIATInterface.sol";
import "./TST20Interface.sol";
import "./CDSDBInterface.sol";
import "./SafeMath.sol";

contract CDS is PermissionGroups {
    using SafeMath for uint;
     /*  CLAY token */
     
    TST20 public CLAY;
    CFIAT public CUSD;
    CFIAT public CCNY;
    CFIAT public CKRW;
    CDSDB public DB;
    
    /* daily retrieveInfo  */
    struct dailyRetrieve {
        address[] TTCApplicants;
        address[] CLAYApplicants;
        uint  totalRetrieveTTC;
        uint  totalRetrieveCLAY;
        mapping(address => uint) TTCAmounts;
        mapping(address => uint) CLAYAmounts;
    }
    mapping(uint => dailyRetrieve) public retrieveInfo;

    uint public constant SECONDS_PER_DAY = 86400;
    uint public constant BASE_DECIMAL = 6;
    uint public constant BASE_PERCENT = 10**BASE_DECIMAL; // 1000,000
    uint public constant liquidationRate = 9*10**(BASE_DECIMAL - 1);
    uint public constant MIN_COLLATERAL_TTC = 100*10**18; 
    uint public constant MIN_COLLATERAL_CLAY = MIN_COLLATERAL_TTC * 10; 

    address public TTCDrawAddress;
    address public CLAYDrawAddress;

    event UO(uint t, address addr, uint value); 
    // user operation 
    // 1 - collateralTTC
    // 2 - collateralCLAY
    // 3 - 5 generateCFIAT CUSD,CCNY,CKRW
    // 6 - 8 returnCFIAT   CUSD,CCNY,CKRW
    // 9 - retrieveTTC
    // 10 - retrieveCLAY
    // 11 - sendTTCToAccount
    // 12 - sendCLAYToAccount
    // 13 - reCalCollateral
    
    function getRetrieveDaily(uint _currentTime, address _addr) public view returns(uint,uint){
        require(_addr != address(0));
        return (retrieveInfo[_currentTime.div(SECONDS_PER_DAY)].TTCAmounts[_addr],retrieveInfo[_currentTime.div(SECONDS_PER_DAY)].CLAYAmounts[_addr]);
    }

    function initAddressSettings(uint _type,address _addr) onlyAdmin public {
        require(_addr != address(0));
        if (_type == 1) {
            CLAY = TST20(_addr);       
        }else if (_type == 2 ) {
            CUSD = CFIAT(_addr);       
        }else if (_type == 3) {
            CCNY = CFIAT(_addr);     
        }else if (_type == 4) {
            CKRW = CFIAT(_addr);  
        }else if (_type == 5) {
            DB = CDSDB(_addr);
        }else if (_type == 6) {
            TTCDrawAddress = _addr;
        }else if (_type == 7) {
            CLAYDrawAddress = _addr;
        }
    }    

    /*collateral TTC */
    function collateralTTC() payable public {
        require(msg.value >= MIN_COLLATERAL_TTC);
        // first collateral TTC
        uint TTCCollateralAmounts;
        uint TTCCollateralTime;
        (TTCCollateralAmounts,TTCCollateralTime) = DB.getTTCCollateralInfo(msg.sender);
        if (TTCCollateralTime == 0) {
            TTCCollateralAmounts = msg.value;
            DB.setTTCCollateralInfo(msg.sender,TTCCollateralAmounts);
        }else {
            uint TTCGain = DB.getTTCGain(msg.sender);
            TTCCollateralAmounts = TTCCollateralAmounts.add(msg.value).add(TTCGain);
            DB.setTTCCollateralInfo(msg.sender,TTCCollateralAmounts);
        }
        UO(1,msg.sender,msg.value);
    }
    
    /*collateral CLAY */
    function collateralCLAY(uint _collateralCLAYAmount) public {
        require(_collateralCLAYAmount >= MIN_COLLATERAL_CLAY);
        CLAY.transferFrom(msg.sender,address(this),_collateralCLAYAmount);
        uint CLAYCollateralAmounts;
        uint CLAYCollateralTime;
        (CLAYCollateralAmounts,CLAYCollateralTime) = DB.getCLAYCollateralInfo(msg.sender);
        if (CLAYCollateralTime == 0) {
            CLAYCollateralAmounts = _collateralCLAYAmount;
            DB.setCLAYCollateralInfo(msg.sender,CLAYCollateralAmounts);
        }else {
            uint TTCCollateralAmounts;
            (TTCCollateralAmounts,CLAYCollateralAmounts) = DB.getAddrTotalCollateral(msg.sender);
            DB.setTTCCollateralInfo(msg.sender,TTCCollateralAmounts);
            CLAYCollateralAmounts = CLAYCollateralAmounts.add(_collateralCLAYAmount);
            DB.setCLAYCollateralInfo(msg.sender,CLAYCollateralAmounts);
        }
        UO(2,msg.sender,_collateralCLAYAmount);
    }

    /*re calculate collateral asset */
    function reCalCollateral() public {
        uint TTCCollateralAmounts;
        uint CLAYCollateralAmounts;
        (TTCCollateralAmounts,CLAYCollateralAmounts) = DB.getAddrTotalCollateral(msg.sender);
        DB.setTTCCollateralInfo(msg.sender,TTCCollateralAmounts);
        DB.setCLAYCollateralInfo(msg.sender,CLAYCollateralAmounts);
        UO(13,msg.sender,0);
    }    


    /* generate CFIAT */
    function generateCFIAT (uint _type,uint _generateAmounts) public  {
        require (_generateAmounts > 0);
        require (_type == 1 || _type ==2 || _type ==3);
        uint serviceFee;
        uint upperGeneratableAmounts;
        uint CUSDAmounts;
        uint CCNYAmounts;
        uint CKRWAmounts;
        (CUSDAmounts,CCNYAmounts,CKRWAmounts,) = DB.getGenerateInfo(msg.sender); 
        if (_type == 1 ) {
            (upperGeneratableAmounts,serviceFee) = DB.getGenerateLimit(1,msg.sender);
            require(_generateAmounts <= upperGeneratableAmounts);
            CUSDAmounts = CUSDAmounts.add(_generateAmounts);
            DB.setGenerateInfo(1,msg.sender,CUSDAmounts,serviceFee);
            CUSD.create(msg.sender,_generateAmounts);
        }else if (_type == 2) {
            (upperGeneratableAmounts,serviceFee) = DB.getGenerateLimit(2,msg.sender);
            require(_generateAmounts <= upperGeneratableAmounts);
            CCNYAmounts = CCNYAmounts.add(_generateAmounts);                                                         
            DB.setGenerateInfo(2,msg.sender,CCNYAmounts,serviceFee);
            CCNY.create(msg.sender,_generateAmounts);
        }else if (_type == 3) {
            (upperGeneratableAmounts,serviceFee) = DB.getGenerateLimit(3,msg.sender);
            require(_generateAmounts <= upperGeneratableAmounts);
            CKRWAmounts = CKRWAmounts.add(_generateAmounts);      
            DB.setGenerateInfo(3,msg.sender,CKRWAmounts,serviceFee);
            CKRW.create(msg.sender,_generateAmounts);
        }
        UO(_type.add(2),msg.sender,_generateAmounts);
    } 
    
    /* return stable coin */
    function returnCFIAT(uint _type,uint _returnAmounts) public {
        require (_type == 1 || _type ==2 || _type == 3);
        uint needToReturnServiceFee;
        uint serviceFee;
        uint CUSDAmounts;
        uint CCNYAmounts;
        uint CKRWAmounts;
        (CUSDAmounts,CCNYAmounts,CKRWAmounts,) = DB.getGenerateInfo(msg.sender); 
        if (_type == 1) {
            (serviceFee,needToReturnServiceFee) = DB.getReturnServiceFee(msg.sender,_returnAmounts,1);
            serviceFee = serviceFee.sub(needToReturnServiceFee);
            CUSDAmounts = CUSDAmounts.sub(_returnAmounts);
            DB.setGenerateInfo(1,msg.sender,CUSDAmounts,serviceFee);
            CLAY.transferFrom(msg.sender,address(this),needToReturnServiceFee);
            CUSD.burn(msg.sender,_returnAmounts);
        } else if (_type == 2) {
            (serviceFee,needToReturnServiceFee) = DB.getReturnServiceFee(msg.sender,_returnAmounts,2);
            serviceFee = serviceFee.sub(needToReturnServiceFee);
            CCNYAmounts = CCNYAmounts.sub(_returnAmounts);                                                         
            DB.setGenerateInfo(2,msg.sender,CCNYAmounts,serviceFee);
            CLAY.transferFrom(msg.sender,address(this),needToReturnServiceFee);
            CCNY.burn(msg.sender,_returnAmounts);
        }else if (_type == 3) {
            (serviceFee,needToReturnServiceFee) = DB.getReturnServiceFee(msg.sender,_returnAmounts,3);
            serviceFee = serviceFee.sub(needToReturnServiceFee);
            CKRWAmounts = CKRWAmounts.sub(_returnAmounts);      
            DB.setGenerateInfo(3,msg.sender,CKRWAmounts,serviceFee);
            CLAY.transferFrom(msg.sender,address(this),needToReturnServiceFee);
            CKRW.burn(msg.sender,_returnAmounts);
        }
        UO(_type.add(5),msg.sender,_returnAmounts);
    }
    /* retrieve TTC*/ 
    function retrieveTTC(uint _retrieveAmounts) public {
        uint availableValueByTTC;
        (availableValueByTTC,,) = DB.getWithdrawable(msg.sender);
        uint TTCCollateralAmounts;
        (TTCCollateralAmounts,) = DB.getAddrTotalCollateral(msg.sender);
        require(_retrieveAmounts <= availableValueByTTC && _retrieveAmounts <= TTCCollateralAmounts);

        // update applicants collateral Info 
        TTCCollateralAmounts = TTCCollateralAmounts.sub(_retrieveAmounts);
        DB.setTTCCollateralInfo(msg.sender,TTCCollateralAmounts);
        // storage daily applicants Info 
        dailyRetrieve storage retrieve = retrieveInfo[now.div(SECONDS_PER_DAY)];
        if (retrieve.TTCAmounts[msg.sender] == 0) {
            retrieve.TTCApplicants.push(msg.sender);
        }
        retrieve.TTCAmounts[msg.sender] = retrieve.TTCAmounts[msg.sender].add(_retrieveAmounts);
        retrieve.totalRetrieveTTC = retrieve.totalRetrieveTTC.add(_retrieveAmounts);
        UO(9,msg.sender,_retrieveAmounts);
    }
    
    /* retrieve CLAY*/ 
    function retrieveCLAY(uint _retrieveAmounts) public {
        uint availableValueByCLAY;
        (,availableValueByCLAY,) = DB.getWithdrawable(msg.sender);
        uint TTCCollateralAmounts;
        uint CLAYCollateralAmounts;
        (TTCCollateralAmounts,CLAYCollateralAmounts) = DB.getAddrTotalCollateral(msg.sender);
        require(_retrieveAmounts <= availableValueByCLAY && _retrieveAmounts <= CLAYCollateralAmounts);
        // update applicants collateral Info 
        CLAYCollateralAmounts = CLAYCollateralAmounts.sub(_retrieveAmounts);
        DB.setTTCCollateralInfo(msg.sender,TTCCollateralAmounts);
        DB.setCLAYCollateralInfo(msg.sender,CLAYCollateralAmounts);
        dailyRetrieve storage retrieve = retrieveInfo[now.div(SECONDS_PER_DAY)];
        if (retrieve.CLAYAmounts[msg.sender] == 0) {
            retrieve.CLAYApplicants.push(msg.sender);
        }
        retrieve.CLAYAmounts[msg.sender] = retrieve.CLAYAmounts[msg.sender].add(_retrieveAmounts);
        retrieve.totalRetrieveCLAY = retrieve.totalRetrieveCLAY.add(_retrieveAmounts);
        UO(10,msg.sender,_retrieveAmounts);
    }
    
    /* liquidation */
    function liquidation(address _addr) public onlyOperator {
        uint accountLiquidationRate;
        uint serviceFee; 
        (accountLiquidationRate,serviceFee) = DB.getCollateralRate(_addr);
        require(accountLiquidationRate >= liquidationRate);
        uint TTCCollateralAmounts;
        uint CLAYCollateralAmounts;
        (TTCCollateralAmounts,CLAYCollateralAmounts) = DB.getAddrTotalCollateral(_addr);
        if (serviceFee > 0){
            CLAY.transferFrom(msg.sender,address(this),serviceFee);
        }
        if (CLAYCollateralAmounts > 0) {
            CLAY.transfer(msg.sender,CLAYCollateralAmounts);
        }
        if (TTCCollateralAmounts > 0) {
            require(msg.sender.send(TTCCollateralAmounts));
        }
        //burn stableCoin
        uint CUSDAmounts;
        uint CCNYAmounts;
        uint CKRWAmounts;
        (CUSDAmounts,CCNYAmounts,CKRWAmounts,) = DB.getGenerateInfo(_addr);
        if (CUSDAmounts > 0) {
            CUSD.burn(msg.sender,CUSDAmounts);
        } 
        if (CCNYAmounts > 0) {
            CCNY.burn(msg.sender,CCNYAmounts);
        } 
        if (CKRWAmounts > 0) {
            CKRW.burn(msg.sender,CKRWAmounts);
        }
        DB.deleteAccount(_addr);
    }
    
    /*send collateral TTC to accounts */
    function sendTTCToAccount(uint _retrieveTime,uint _beginIndex, uint _endIndex) onlyOperator public {
        dailyRetrieve storage retrieve = retrieveInfo[_retrieveTime.div(SECONDS_PER_DAY)];
        if (_endIndex > retrieve.TTCApplicants.length){
            _endIndex = retrieve.TTCApplicants.length;
        }
        for (uint i=_beginIndex; i < _endIndex ; i++) {
            address sendAddr = retrieve.TTCApplicants[i];
            if (retrieve.TTCAmounts[sendAddr] > 0) {
                require(sendAddr.send(retrieve.TTCAmounts[sendAddr]));
                UO(11,sendAddr,retrieve.TTCAmounts[sendAddr]);
                retrieve.TTCAmounts[sendAddr] = 0;
            }
        }
    }
    
    /*send collateral CLAY to accounts */
    function sendCLAYToAccount(uint _retrieveTime,uint _beginIndex, uint _endIndex) onlyOperator public {
        dailyRetrieve storage retrieve = retrieveInfo[_retrieveTime.div(SECONDS_PER_DAY)];
        if (_endIndex > retrieve.CLAYApplicants.length){
            _endIndex = retrieve.CLAYApplicants.length;
        }
        for (uint i=_beginIndex; i < _endIndex ; i++) {
            address sendAddr = retrieve.CLAYApplicants[i];
            if (retrieve.CLAYAmounts[sendAddr] > 0) {
                CLAY.transfer(sendAddr,retrieve.CLAYAmounts[sendAddr]);
                UO(12,sendAddr,retrieve.CLAYAmounts[sendAddr]);
                retrieve.CLAYAmounts[sendAddr] = 0;
            }
        }
    }

    /* charge ttc into contract */
    function chargeTTC() payable public  {
    }

    /*withdraw TTC by operator */
    function withdrawTTC() onlyOperator public {
        require(TTCDrawAddress.send(this.balance));
    }
    
    /*withdraw CLAY by operator */
    function withdrawCLAY() onlyOperator public {
        CLAY.transfer(CLAYDrawAddress,CLAY.balanceOf(this));
    }
}
