pragma solidity ^0.4.19;

import "./TST20Interface.sol";
import "./OracleInterface.sol";
import "./PermissionGroups.sol";
import "./SafeMath.sol";

contract TSS is PermissionGroups{
    
    using SafeMath for uint;
    
    TST20 public CLAY;
    TST20 public CUSD;
    TST20 public CCNY;
    TST20 public CKRW;
    
    ORC public USD_TTC;
    ORC public CNY_TTC;
    ORC public KRW_TTC;
    ORC public CLAY_TTC;

    ORC public VOTE_REWARD;

    uint public denominator = 10000;


    struct DepositRecord {
        uint time;
        uint value;
    }
	
    mapping(address => string) acceptCollateralToken; 
    string[] public tokenList;

    mapping(address => DepositRecord) public collateralTTC;
    mapping(address => mapping(address => DepositRecord)) public collateralTokens;
 
    function setVoteReward(address _tokenAddress) onlyAdmin public {
        require(_tokenAddress != address(0));
        VOTE_REWARD = ORC(_tokenAddress);
    }

    function addAcceptCollateralToken(address _tokenAddress, string _name) onlyAdmin public {
        require(_tokenAddress != address(0));
        if (keccak256(acceptCollateralToken[_tokenAddress]) == keccak256("")) {
            acceptCollateralToken[_tokenAddress] = _name;
            tokenList.push(_name);
        }
    }

    function isAcceptCollateralToken(address _tokenAddress) view public returns (string) {
        return acceptCollateralToken[_tokenAddress];
    }



    function() payable public{
        DepositRecord storage record = collateralTTC[msg.sender] ;
        uint newValue = recalculateDeposit(record);
        //uint newValue = getTestValue();
        record.value = newValue.add(msg.value);
        record.time = block.timestamp;

    }

    function recalculateDeposit(DepositRecord _record) internal view returns (uint) {
        // base on time and value
        // and get rate from oracle
        
        uint value = VOTE_REWARD.getValue(block.number);
        uint value2 = _record.value.mul(denominator+value);
        uint value3 = value2.div(denominator);
        return value3;
        
    }


}