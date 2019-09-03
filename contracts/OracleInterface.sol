pragma solidity ^0.4.19;

interface ORC {
    function setValidDistance(uint _validDistance)  public;
	function setValue(uint _value) public ;
	function getValue(uint _blockNumber) public view returns (uint);

}