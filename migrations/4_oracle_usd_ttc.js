var USDTTC = artifacts.require("./ORACLE.sol");

module.exports = function(deployer) {
  deployer.deploy(USDTTC);
};
