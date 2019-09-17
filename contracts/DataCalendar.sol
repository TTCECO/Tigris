pragma solidity ^0.4.19;

import "./PermissionGroups.sol";
import "./OracleInterface.sol";
import "./SafeMath.sol";

contract DataCalendar is PermissionGroups{

    using SafeMath for uint;

    uint public constant SECONDS_PER_DAY = 86400;

    string public name = "DataCalendar";
    ORC public sourceOrcale;
    mapping(uint => uint) public dailyData; 	// timestamp/86400 => value
    uint public minDate;
    uint public maxDate;

    /* set name of oracle */
    function setName(string _name) onlyAdmin public {
        name = _name;
    }

    /* set sourceOrcale */
    function setSourceOrcale(address _addr) onlyAdmin public {
    	require(_addr != address(0));
    	sourceOrcale = ORC(_addr);
    }

    function updateRecord() onlyOperator public {
    	uint date = now.div(SECONDS_PER_DAY);
    	if (dailyData[date] != 0){
    		return;
    	}
    	dailyData[date] = sourceOrcale.getLatestValue();
    	maxDate = date;
    	if (minDate == 0){
    		minDate = date;
    	}
    }

    function getValue(uint _start, uint _end) public view returns (uint) {
    	uint start = _start.div(SECONDS_PER_DAY);
    	uint end = _end.div(SECONDS_PER_DAY);

    	if (start < minDate) {
    		start = minDate;
    	}
    	if (end > maxDate) {
    		end  = maxDate;
    	}

    	uint sum = 0;
    	for (uint i = start; i <= end; i++){
    		sum = sum.add(dailyData[i]);
    	}
    	return sum;
    }

    function replaceValue(uint _time, uint _value) onlyOperator public {
    	uint date = _time.div(SECONDS_PER_DAY);
    	dailyData[date] = _value;
    	if (date > maxDate ) {
    		maxDate = date;
    	}
    }

}    
