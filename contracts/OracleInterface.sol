pragma solidity ^0.4.19;

interface Oracle {
    function getLatestValue() public view returns(uint);

}
