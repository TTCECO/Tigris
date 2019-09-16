pragma solidity ^0.4.19;

import "./PermissionGroups.sol";
import "./SafeMath.sol";

contract ORACLE is PermissionGroups{

    using SafeMath for uint;

    string public name = "ORACLE";
    uint public validDistance = 20;
    uint public minSourceNum = 3;
    bool public isRemoveMaxMin = true;
    uint public minRecordNum = 5;  // min Record block number for each source

    mapping (uint => mapping (address => uint)) valueRecord;
    mapping (uint => mapping (uint => uint)) detailRecord; // 0-min / 1-max / 2-sum / 3-cnt
    uint[] public blockList;


    /* set name of oracle */
    function setName(string _name) onlyOperator public {
        name = _name;
    }

    /* set valid distance */
    function setValidDistance(uint _validDistance) onlyOperator public {
        validDistance = _validDistance;
    }

    /* set min source number */
    function setMinSourceNum(uint _minSourceNum) onlyOperator public {
        minSourceNum = _minSourceNum;
    }

    /* is remove max & min value */
    function setIsRemoveMaxMin(bool _isRemoveMaxMin) onlyOperator public {
        isRemoveMaxMin = _isRemoveMaxMin;
    }

    function setMinRecordNum(uint _minRecordNum) onlyOperator public {
        minRecordNum = _minRecordNum;
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
                detailRecord[num][2] += _value;
                detailRecord[num][3] += 1;
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

            if (detailRecord[num][3] < minSourceNum) {
                continue;
            }

            if (isRemoveMaxMin) {
                return detailRecord[num][2].sub(detailRecord[num][0]).sub(detailRecord[num][1]).div(detailRecord[num][3].sub(2)); 
            }else{
                return detailRecord[num][2].div(detailRecord[num][3]); 
            }
        }

        require(false);
        return 0;

    }
    
}