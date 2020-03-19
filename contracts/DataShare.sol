pragma solidity ^0.4.19;

import "./PermissionGroups.sol";
import "./SafeMath.sol";

contract DataShare is PermissionGroups{
    using SafeMath for uint;
    string public name = "DataShare";
    uint public curData = 0;
    uint public curCnt = 0;
    mapping(uint => uint) public historyData;

    /* set the name of data share*/
    function setName(string _name) onlyAdmin public {
        name = _name;
    }

    /* add value to cur data */
    function addData(uint _value) onlyOperator public {
        curData += _value;
    }

    /* zip data into history data */
    function zipData() onlyOperator public {
        historyData[curCnt] = curData;
        curData = 0;
        curCnt++;
    }
}

