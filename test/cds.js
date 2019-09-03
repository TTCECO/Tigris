var CUSD = artifacts.require("./CFIAT.sol");
var CDS = artifacts.require("./CDS.sol");
var USDTTC = artifacts.require("./ORACLE.sol");
var CLAY = artifacts.require("./CLAY.sol");

contract('CDS', function() {
	var eth = web3.eth;
  var owner = eth.accounts[0];
  var operator_1 = eth.accounts[1];


	it("get admin ",async () =>  {
        const cds = await CDS.deployed();
        admin = await cds.admin.call()
        assert.equal(admin, owner, "equal")
  });

  it("admin set operator  ",async () =>  {
        const cds = await CDS.deployed();
        await cds.addOperator(operator_1, {from:owner});
        operator = await cds.getOperators.call();
        assert.equal(operator[0], operator_1, "equal");
  });

});



















