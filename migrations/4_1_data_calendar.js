var TTCGainRate = artifacts.require("./DataCalendar.sol");

module.exports = function(deployer) {
  deployer.deploy(TTCGainRate);
};