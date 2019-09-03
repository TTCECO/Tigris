var CLAYTTC = artifacts.require("./ORACLE.sol");
var CNYTTC = artifacts.require("./ORACLE.sol");
var KRWTTC = artifacts.require("./ORACLE.sol");
var USDTTC = artifacts.require("./ORACLE.sol");

module.exports = function(deployer) {
  deployer.deploy([CLAYTTC,CNYTTC,KRWTTC,USDTTC]);
};