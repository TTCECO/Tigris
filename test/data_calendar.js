var SourceOrc = artifacts.require("./Oracle.sol");
var DC = artifacts.require("./DataCalendar.sol");


contract('ORACLE', function() {
	var eth = web3.eth;
  var owner = eth.accounts[0];
  var operator_1 = eth.accounts[1];
  var operator_2 = eth.accounts[2];
  var operator_3 = eth.accounts[3];
  var operator_4 = eth.accounts[4];
  var operator_5 = eth.accounts[5];

  var validDistance = 10; // about one minutes
  var contractName = "USD_TTC";
  var minRecordNum = 8;



	it("get admin",async () =>  {
        const ut = await SourceOrc.deployed();
        admin = await ut.admin.call()
        assert.equal(admin, owner, "equal")

        const dc = await DC.deployed();
        admin = await dc.admin.call()
        assert.equal(admin, owner, "equal")

  });

  it("admin set operator",async () =>  {
        const ut = await SourceOrc.deployed();
        await ut.addOperator(operator_1, {from:owner});
        await ut.addOperator(operator_2, {from:owner});
        await ut.addOperator(operator_3, {from:owner});
        await ut.addOperator(operator_4, {from:owner});
        await ut.addOperator(operator_5, {from:owner});
        operators = await ut.getOperators.call();
        assert.equal(operators[0], operator_1, "equal");
        assert.equal(operators[1], operator_2, "equal");
        assert.equal(operators[2], operator_3, "equal");


        const dc = await DC.deployed();
        await dc.addOperator(operator_1, {from:owner});
        operators = await dc.getOperators.call();
        assert.equal(operators[0], operator_1, "equal");

  });

  it("admin settings ",async () =>  {
        const ut = await SourceOrc.deployed();
        await ut.setName(contractName, {from:owner});
        name = await ut.name.call();
        assert.equal(contractName, name, "equal");

        await ut.setValidDistance(validDistance, {from:owner});
        res = await ut.validDistance.call();
        assert.equal(res, validDistance, "equal");

        await ut.setMinRecordNum(minRecordNum, {from:owner});
        res = await ut.minRecordNum.call();
        assert.equal(res, minRecordNum, "equal");

        await ut.setIsRemoveMaxMin(true, {from:owner});
        res = await ut.isRemoveMaxMin.call();
        assert.equal(res, true, "equal");

        await ut.setMinSourceNum(3, {from:owner});
        res = await ut.minSourceNum.call();
        assert.equal(res, 3, "equal");

        await ut.setLastValue(150, {from:owner});
        res = await ut.lastValue.call();
        assert.equal(res, 150, "equal");

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
