pragma solidity ^0.4.19;

import "./PermissionGroups.sol";
import "./SafeMath.sol";

contract ORACLE is PermissionGroups{
    string public name = "ORACLE";
    using SafeMath for uint;
    uint public validDistance = 0;
    mapping (uint => mapping (address => uint)) valueRecord;
    uint[] public blockList;

    function setName(string _name) onlyAdmin public {
    	name = _name;
    }

    function setValidDistance(uint _validDistance) onlyOperator public {
    	validDistance = _validDistance;
    }

    function setValue(uint _value) onlyOperator public {
        if (valueRecord[block.number][msg.sender] == 0 ){
        	valueRecord[block.number][msg.sender] = _value;
			if (blockList.length == 0 || blockList[blockList.length-1] < block.number ) {
        		blockList.push(block.number);
        	} 
        }

    }

    function getValue(uint _blockNumber) public view returns (uint){
        uint count = 0;
        uint valueSum = 0;
    	for (uint num = _blockNumber.sub(validDistance); num <_blockNumber; num ++ ){
    		for (uint i = 0; i < operatorsGroup.length; ++i) {
	            if (valueRecord[num][operatorsGroup[i]] > 0 ) {
	            	count++;
	            	valueSum += valueRecord[num][operatorsGroup[i]];
	            }
	        }
    	}
        if (count > 0) {
        	return valueSum.div(count);
        }
    	return 0;
    }
	
}