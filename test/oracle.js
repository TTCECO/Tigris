var USDTTC = artifacts.require("./Oracle.sol");

contract('ORACLE', function() {
	var eth = web3.eth;
  var owner = eth.accounts[0];
  var operator_1 = eth.accounts[1];
  var operator_2 = eth.accounts[2];
  var operator_3 = eth.accounts[3];
  var operator_4 = eth.accounts[4];
  var operator_5 = eth.accounts[5];

  var validDistance = 25; // about one minutes
  var contractName = "USD_TTC";
  var minRecordNum = 5;



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
        await ut.addOperator(operator_4, {from:owner});
        await ut.addOperator(operator_5, {from:owner});
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

  it("admin set valid distance",async () =>  {
        const ut = await USDTTC.deployed();
        await ut.setValidDistance(validDistance, {from:owner});
        res = await ut.validDistance.call();
        assert.equal(res, validDistance, "equal");
  });

  it("admin set minRecordNum",async () =>  {
        const ut = await USDTTC.deployed();

        await ut.setMinRecordNum(minRecordNum, {from:owner});
        res = await ut.minRecordNum.call();
        assert.equal(res, minRecordNum, "equal");

  });


  it("operators set value , not remove min & max ",async () =>  {
        const ut = await USDTTC.deployed();

        await ut.setMinSourceNum(2, {from:owner});
        res = await ut.minSourceNum.call();
        assert.equal(res, 2, "equal");


        await ut.setIsRemoveMaxMin(false, {from:owner});
        res = await ut.isRemoveMaxMin.call();
        assert.equal(res, false, "equal");


        await ut.setLastValue(145, {from:owner});
        res = await ut.lastValue.call();
        assert.equal(res, 145, "equal");

        await ut.setValue(145, {from:operator_1});
        await ut.setValue(146, {from:operator_2});
        await ut.setValue(153, {from:operator_3});

        res = await ut.getLatestValue.call();
        assert.equal(res >= 145, true, "equal");
        assert.equal(res <= 153, true, "equal");

  });


  it("operators set value, remove min & max",async () =>  {
        const ut = await USDTTC.deployed();
 
        await ut.setIsRemoveMaxMin(true, {from:owner});
        res = await ut.isRemoveMaxMin.call();
        assert.equal(res, true, "equal");

        await ut.setMinSourceNum(3, {from:owner});
        res = await ut.minSourceNum.call();
        assert.equal(res, 3, "equal");

        await ut.setValue(145, {from:operator_1});
        await ut.setValue(146, {from:operator_2});
        await ut.setValue(153, {from:operator_3});
        await ut.setValue(156, {from:operator_4});
        await ut.setValue(153, {from:operator_5});

        res = await ut.getLatestValue.call();
        assert.equal(res >= 146, true, "equal");
        assert.equal(res <= 153, true, "equal");

  });

});
