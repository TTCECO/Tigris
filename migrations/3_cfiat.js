var CCNY = artifacts.require("./CFIAT.sol");
var CKRW = artifacts.require("./CFIAT.sol");
var CUSD = artifacts.require("./CFIAT.sol");
module.exports = function(deployer) {
  deployer.deploy([CCNY,CKRW,CUSD]);
};

