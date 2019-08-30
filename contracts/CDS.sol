pragma solidity ^0.4.19;

import "./TST20Interface.sol";
import "./PermissionGroups.sol";
import "./SafeMath.sol";

contract CDS is PermissionGroups{
    
    using SafeMath for uint;
    /*  CLAY token */
    TST20 public CLAY;

    /*  Receive TTC */
    function() payable public {}

    /* set CLAY */
	function setCLAYAddress(address _CLAYAddr) onlyOperator public {
	    require(_CLAYAddr != address(0));
	    CLAY = TST20(_CLAYAddr);
	}
	
	function getCLAYAddress() public view returns(address) {
	    return CLAY;
	}
	
}