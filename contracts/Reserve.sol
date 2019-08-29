pragma solidity ^0.4.19;

import "./TST20Interface.sol";
import "./PermissionGroups.sol";
import "./SafeMath.sol";

contract Reserve is PermissionGroups{
    
    using SafeMath for uint;
    /*  CLAY token */
    TST20 public CLAY;

    address public CLAYReserveAddress;
    uint public TTCReserve;
    uint public lastMonthTTCReserve;
    uint public totalPercent = 100;
    uint public lastMonthlyPercent = 2;
    uint public monthlyGrowthPercent = 20;
    
    
    /*  Receive TTC */
    function() payable public { }

    /* set CLAY */
	function setCLAYAddress(address _CLAYAddr) onlyOperator public {
	    require(_CLAYAddr != address(0));
	    CLAY = TST20(_CLAYAddr);
	}
	
	function getCLAYAddress() public view returns(address) {
	    return CLAY;
	}
	
	/* draw  CLAY  */
	function drawCLAY() onlyAdmin public {
	    uint CLAYReserve = CLAY.balanceOf(this);
		require(CLAYReserve > 0);
		CLAY.transfer(CLAYReserveAddress,CLAYReserve);
	}
	
	
	/* monthlyMaintain For TTC*/
	function monthlyMaintain(uint _lastMonthTTCReserve, uint _monthlyGrowthPercent)   public view  returns (uint){
	    uint monthlyMaintainTTC = _lastMonthTTCReserve.mul(lastMonthlyPercent).add(_monthlyGrowthPercent.mul(monthlyGrowthPercent)).div(totalPercent);
	    return monthlyMaintainTTC;
	}
	
	
	/* CLAY  & TTCReserve*/
	function setTTCReserve(uint _TTCReserve) onlyOperator public {
	    TTCReserve = _TTCReserve;
	    
	}
	
	/* CLAY  & TTC balance*/
	function getTotalReserve() public view returns(uint,uint){
	    uint CLAYReserve = CLAY.balanceOf(CLAYReserveAddress);
	    return (CLAYReserve,TTCReserve);
	}

	/* set CLAYReserveAddress*/
	function setCLAYDrawAddress(address _addr) public onlyOperator {
	    CLAYReserveAddress = _addr;
	}
	

	/* set monthly maintainPercent*/
	function setMonthlyMaintainPercent(uint _monthlyPercent, uint _growthPercent) public onlyOperator {
	    lastMonthlyPercent = _monthlyPercent;
	    monthlyGrowthPercent = _growthPercent;
	}
	

	
}