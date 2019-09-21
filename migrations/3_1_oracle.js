var CUSD2TTC = artifacts.require("./Oracle.sol");

module.exports = function(deployer) {
  deployer.deploy(CUSD2TTC);
};