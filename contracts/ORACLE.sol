pragma solidity ^0.4.19;

import "./PermissionGroups.sol";
import "./SafeMath.sol";

contract ORACLE is PermissionGroups{
    string public name = "ORACLE";
    using SafeMath for uint;
    uint public validBlockLength = 0;
    mapping (uint => mapping (address => uint)) valueRecord;
    uint[] public blockList;

    function setName(string _name) onlyAdmin public {
    	name = _name;
    }

    function setValidBlockLength(uint _validBlockLength) onlyOperator public {
    	validBlockLength = _validBlockLength;
    }

    function setValue(uint _value) onlyOperator public {
        valueRecord[block.number][msg.sender] = _value;
        if (blockList[blockList.length-1] < block.number) {
        	blockList.push(block.number);
        }  
    }

    function getValue(uint _number) public view returns (uint){
    	if (blockList[blockList.length-1] + validBlockLength > _number) {
	        uint count = 0;
	        uint valueSum = 0;
	        for (uint i = 0; i < operatorsGroup.length; ++i) {
	            if (valueRecord[block.number][operatorsGroup[i]] > 0 ) {
	            	count++;
	            	valueSum += valueRecord[block.number][operatorsGroup[i]];
	            }
	        }
	        if (count > 0) {
	        	return valueSum.div(count);
	        }
    	}

    	return 0;
    }
	
}