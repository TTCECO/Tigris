pragma solidity ^0.4.19;

import "./PermissionGroups.sol";
import "./SafeMath.sol";

contract Oracle is PermissionGroups{

    using SafeMath for uint;

    string public name = "ORACLE";
    uint public validDistance = 20;
    uint public minSourceNum = 3;
    bool public isRemoveMaxMin = true;
    uint public minRecordNum = 5;  // min Record block number for each source
    uint public changeRateInMillion = 50000; // change rate , default 50,000/1000,000
    uint public lastValue = 0;  // do not use this as value, because valid distance

    mapping (uint => mapping (address => uint)) public valueRecord;
    mapping (uint => mapping (uint => uint)) public detailRecord; // 0-min / 1-max / 2-sum / 3-cnt / 4-fixed
    uint[] public blockList;


    /* set name of oracle */
    function setName(string _name) onlyAdmin public {
        name = _name;
    }

    /* set valid distance */
    function setValidDistance(uint _validDistance) onlyAdmin public {
        validDistance = _validDistance;
    }

    /* set min source number */
    function setMinSourceNum(uint _minSourceNum) onlyAdmin public {
        minSourceNum = _minSourceNum;
    }

    /* is remove max & min value */
    function setIsRemoveMaxMin(bool _isRemoveMaxMin) onlyAdmin public {
        isRemoveMaxMin = _isRemoveMaxMin;
    }

    function setMinRecordNum(uint _minRecordNum) onlyAdmin public {
        minRecordNum = _minRecordNum;
    }

    function setChangeRate(uint _changeRateInMillion) onlyAdmin public {
        changeRateInMillion = _changeRateInMillion;
    }

    function setLastValue(uint _lastValue) onlyAdmin public {
        lastValue = _lastValue;
    }

    /* set value by operator */    
    function setValue(uint _value) onlyOperator public {
        uint num = block.number.div(minRecordNum).mul(minRecordNum);
        if (valueRecord[num][msg.sender] == 0 ){
            valueRecord[num][msg.sender] = _value;

            if (blockList.length == 0 || blockList[blockList.length-1] < num ) {                
                blockList.push(num);
                detailRecord[num][0] = _value;
                detailRecord[num][1] = _value;
                detailRecord[num][2] = _value;
                detailRecord[num][3] = 1;
            } else {
                if (_value < detailRecord[num][0]) {
                    detailRecord[num][0] = _value;
                }else if (_value > detailRecord[num][1]) {
                    detailRecord[num][1] = _value;
                }
                detailRecord[num][2] = detailRecord[num][2].add(_value);
                detailRecord[num][3] += 1;
            } 

            if (detailRecord[num][4] == 0 && detailRecord[num][3] == minSourceNum) {
                if (isRemoveMaxMin) {
                    detailRecord[num][4] = detailRecord[num][2].sub(detailRecord[num][0]).sub(detailRecord[num][1]).div(detailRecord[num][3].sub(2)); 
                }else{
                    detailRecord[num][4] = detailRecord[num][2].div(detailRecord[num][3]); 
                }

                uint diff = lastValue.mul(changeRateInMillion).div(10**6);

                if (detailRecord[num][4] > lastValue.add(diff)) {
                    detailRecord[num][4] = lastValue.add(diff);
                }else if(detailRecord[num][4] < lastValue.sub(diff))  {
                    detailRecord[num][4] = lastValue.sub(diff);
                }
                lastValue = detailRecord[num][4];
            } 

        }
    }

    /* getValue by public */
    function getLatestValue() public view returns (uint){
        for (uint i= blockList.length - 1; i >= 0; i--) {
            uint num = blockList[i];
            if (num < block.number - validDistance) {
                break;
            }
            if (detailRecord[num][4] != 0 || detailRecord[num][3] >= minSourceNum) {
                return detailRecord[num][4];
            }
        }

        require(false);
        return 0;

    }
    
}
