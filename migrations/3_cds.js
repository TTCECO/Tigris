var CDS = artifacts.require("./CDS.sol");
var CLAY = artifacts.require("./CLAY.sol");


module.exports = function(deployer) {
	var owner = web3.eth.accounts[0];

  	return deployer.deploy(CLAY).then(function(){
  		return deployer.deploy(CDS).then(function(){
			return CDS.deployed().then(function(cds){
				cds.initAddressSettings(1,CLAY.address,{from:owner});
			});
		});
	});
	deployer.deploy(CDS);
};
