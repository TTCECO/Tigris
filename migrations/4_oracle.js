var CLAYTTC = artifacts.require("./Oracle.sol");
var CNYTTC = artifacts.require("./Oracle.sol");
var KRWTTC = artifacts.require("./Oracle.sol");
var USDTTC = artifacts.require("./Oracle.sol");

module.exports = function(deployer) {
  deployer.deploy([CLAYTTC,CNYTTC,KRWTTC,USDTTC]);
};