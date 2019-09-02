pragma solidity ^0.4.19;

import "./PermissionGroups.sol";
import "./SafeMath.sol";

contract ORACLE is PermissionGroups{
    string public name = "ORACLE";
    using SafeMath for uint;
    uint public constant decimals = 18;

    function setName(string _name) onlyAdmin public {
    	name = _name;
    }
	
}