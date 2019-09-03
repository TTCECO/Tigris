pragma solidity ^0.4.19;

import "./TST20Interface.sol";
import "./OracleInterface.sol";
import "./PermissionGroups.sol";
import "./SafeMath.sol";

contract CDS is PermissionGroups{
    
    using SafeMath for uint;
    
    TST20 public CLAY;
    TST20 public CUSD;
    TST20 public CCNY;
    TST20 public CKRW;
    
    ORC public USDTTC;
    ORC public CNYTTC;
    ORC public KRWTTC;
    ORC public CLAYTTC;
	
}