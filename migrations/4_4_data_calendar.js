var serviceFeeRate = artifacts.require("./DataCalendar.sol");

module.exports = function(deployer) {
  deployer.deploy(serviceFeeRate);
};