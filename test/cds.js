var CUSD = artifacts.require("./CFIAT.sol");
var CDS = artifacts.require("./CDS.sol");
var USDTTC = artifacts.require("./ORACLE.sol");

contract('CDS', function() {
	var eth = web3.eth;
  var owner = eth.accounts[0];


	it("get admin ",async () =>  {
        const cds = await CDS.deployed();
        const cusd = await CUSD.deployed();
        admin = await cds.admin.call()
        assert.equal(admin, owner, "equal")
  });

  it("admin set operator  ",async () =>  {
        const cds = await CDS.deployed();
        await cds.addOperator(owner, {from:owner});
        operator = await cds.getOperators.call();
        assert.equal(operator[0], owner, "equal");
  });

});



















