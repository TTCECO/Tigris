pragma solidity ^0.4.19;

import "./PermissionGroups.sol";
import "./OracleInterface.sol";
import "./SafeMath.sol";

contract DataCalendar is PermissionGroups{

    using SafeMath for uint;

    uint public constant SECONDS_PER_DAY = 86400;

    string public name = "DataCalendar";
    ORC public sourceOrcale;
    mapping(uint => uint) public dailyData;
    mapping(uint => uint) public dateIndex;
    uint[] public dateList;

    /* set name of oracle */
    function setName(string _name) onlyAdmin public {
        name = _name;
    }

    /* set sourceOrcale */
    function setSourceOrcale(address _addr) onlyAdmin public {
    	require(_addr != address(0));
    	sourceOrcale = ORC(_addr);
    }

    function updateRecord() onlyOperator public returns (uint) {
    	uint date = now.div(SECONDS_PER_DAY);
    	if (dailyData[date] != 0){
    		return 0;
    	}
    	uint value = sourceOrcale.getLatestValue();
    	dailyData[date] = value;
    	dateIndex[date] = dateList.length;
    	dateList.push(date);
    	return value;
    }

    function getValue(uint _start, uint _end) public view returns (uint) {
    	uint start = _start.div(SECONDS_PER_DAY);
    	uint end = _end.div(SECONDS_PER_DAY);
    	uint startPos = 0;
    	uint endPos = dateList.length;
    	if (start >= dateList[0] && start <= dateList[dateList.length-1]){
    		startPos = dateIndex[start];
    		if (startPos == 0) {
    			for (uint i=start+1; i <= dateList[dateList.length-1];i++ ){
    				if (dateIndex[i] != 0) {
    					startPos = dateIndex[i];
    					break;
    				}
    			}
    		}
    	}else if (start > dateList[dateList.length-1]) {
    		return 0;
    	}
    	if (end >= dateList[0] && end <= dateList[dateList.length-1]){
    		endPos = dateIndex[end];
    		if (endPos == 0) {
    			for (i=end-1; i > dateList[0];i-- ){
    				if (dateIndex[i] != 0) {
    					endPos = dateIndex[i];
    					break;
    				}
    			}
    		}
    	}else if (end < dateList[0]) {
    		return 0;
    	}

    	uint sum = 0;
    	for (i = startPos; i <= endPos; i++){
    		sum = sum.add(dailyData[dateList[i]]);
    	}
    	return sum;
    }

}    
