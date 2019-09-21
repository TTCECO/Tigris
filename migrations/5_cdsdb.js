var CDSDB = artifacts.require("./CDSDatabase.sol");

module.exports = function(deployer) {
  deployer.deploy(CDSDB);
};