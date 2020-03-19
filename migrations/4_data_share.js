var DS = artifacts.require("./DataShare.sol");

module.exports = function(deployer) {
  deployer.deploy(DS);
};
