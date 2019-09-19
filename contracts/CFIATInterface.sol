pragma solidity ^0.4.19;

// https://github.com/ethereum/EIPs/issues/20
interface CFIAT  {
    function transfer(address _to, uint _value) external;
    function transferFrom(address _from, address _to, uint _value) external;
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function create(address _addr, uint _value)  public returns (bool);
    function burn(address _addr, uint _value)  public returns (bool);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
}
