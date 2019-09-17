pragma solidity ^0.4.19;

import "./PermissionGroups.sol";
import "./OracleInterface.sol";
import "./SafeMath.sol";

contract DataCalendar is PermissionGroups{

    using SafeMath for uint;

    string public name = "DataCalendar";

    ORC public sourceOrcale;

    /* set name of oracle */
    function setName(string _name) onlyAdmin public {
        name = _name;
    }

    /* set sourceOrcale */
    function setSourceOrcale(address _addr) onlyAdmin public {
    	require(_addr != address(0));
    	sourceOrcale = ORC(_addr);
    }

    function updateRecord() onlyOperator public view returns (uint) {
    	uint value = sourceOrcale.getLatestValue();
    	return value;
    }

}    
