var reserveGainRate = artifacts.require("./DataCalendar.sol");

module.exports = function(deployer) {
  deployer.deploy(reserveGainRate);
};