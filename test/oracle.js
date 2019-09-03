var USDTTC = artifacts.require("./ORACLE.sol");

contract('ORACLE', function() {
	var eth = web3.eth;
  var owner = eth.accounts[0];
  var operator_1 = eth.accounts[1];
  var operator_2 = eth.accounts[2];
  var operator_3 = eth.accounts[3];


  var initalCUSD = 0 * 10 **18;
  var validLen = 4; // about one minutes
  var contractName = "USDTTC";

	it("get admin",async () =>  {
        const ut = await USDTTC.deployed();
        admin = await ut.admin.call()
        assert.equal(admin, owner, "equal")
  });

  it("admin set operator",async () =>  {
        const ut = await USDTTC.deployed();
        await ut.addOperator(operator_1, {from:owner});
        await ut.addOperator(operator_2, {from:owner});
        await ut.addOperator(operator_3, {from:owner});
        operators = await ut.getOperators.call();
        assert.equal(operators[0], operator_1, "equal");
        assert.equal(operators[1], operator_2, "equal");
        assert.equal(operators[2], operator_3, "equal");
  });

  it("admin set name",async () =>  {
        const ut = await USDTTC.deployed();
        await ut.setName(contractName, {from:owner});
        name = await ut.name.call();
        assert.equal(contractName, name, "equal");
  });

  it("admin set valid length",async () =>  {
        const ut = await USDTTC.deployed();
        await ut.setValidDistance(validLen, {from:operator_1});
        validLen = await ut.validDistance.call();
        assert.equal(validLen, validLen, "equal");
  });

  it("admin set value",async () =>  {
        const ut = await USDTTC.deployed();
        blockNumber = await web3.eth.blockNumber + 5; // next 3 txs 
        ut.setValue(145, {from:operator_1});
        ut.setValue(146, {from:operator_2});
        ut.setValue(153, {from:operator_3});

        res = await ut.getValue.call(blockNumber);
        assert.equal((145+146+153)/3, res, "equal");
  });
});
