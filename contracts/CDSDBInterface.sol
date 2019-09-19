pragma solidity ^0.4.19;

interface CDSDB {
    function getTTCCollateralInfo (address _addr) public view returns(uint,uint);
    function getCLAYCollateralInfo (address _addr) public view returns(uint,uint);
    function setTTCCollateralInfo (address _addr, uint _TTCCollateralAmounts) public;
    function setCLAYCollateralInfo (address _addr, uint _CLAYCollateralAmounts) public ;
    function getTTCGain(address _addr) public returns (uint);
    function getCLAYGain(address _addr) public returns (uint,uint);
    function getWithdrawable(address _addr) public returns(uint,uint,uint);
    function getGenerateInfo(address _addr) public view returns (uint,uint,uint,uint);
    function setGenerateInfo(uint _type,address _addr,uint _changedAmounts,uint _changedServiceFee) public;
    function getGenerateLimit(uint _type, address _addr) public returns(uint,uint);
    function getReturnServiceFee(address _addr,uint _returnAmounts,uint _type) public returns(uint,uint);
    function getCollateralRate(address _addr) public returns(uint,uint);
    function getAddrTotalCollateral(address _addr) public returns (uint,uint);
    function deleteAccount(address _addr) public;
}
