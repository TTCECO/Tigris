var CUSD = artifacts.require("./CFIAT.sol");

module.exports = function(deployer) {
  deployer.deploy(CUSD);
};

