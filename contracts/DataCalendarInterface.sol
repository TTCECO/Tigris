pragma solidity ^0.4.19;

interface DC {
	function getValue(uint _start, uint _end) public view returns (uint);
}