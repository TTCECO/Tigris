var USDTTC = artifacts.require("./Oracle.sol");

contract('ORACLE', function() {
	var eth = web3.eth;
  var owner = eth.accounts[0];
  var operator_1 = eth.accounts[1];
  var operator_2 = eth.accounts[2];
  var operator_3 = eth.accounts[3];

  var validDistance = 25; // about one minutes
  var contractName = "USD_TTC";
  var minSourceNum = 2;
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
        operators = await ut.getOperators.call();
        assert.equal(operators[0], operator_1, "equal");
        assert.equal(operators[1], operator_2, "equal");
        assert.equal(operators[2], operator_3, "equal");
  });

  it("admin set name",async () =>  {
        const ut = await USDTTC.deployed();
        await ut.setName(contractName, {from:operator_1});
        name = await ut.name.call();
        assert.equal(contractName, name, "equal");
  });

  it("admin set valid distance",async () =>  {
        const ut = await USDTTC.deployed();
        await ut.setValidDistance(validDistance, {from:operator_1});
        res = await ut.validDistance.call();
        assert.equal(res, validDistance, "equal");
  });

  it("admin set min source number , isRemoveMaxMin and minRecordNum",async () =>  {
        const ut = await USDTTC.deployed();

        await ut.setMinSourceNum(minSourceNum, {from:operator_1});
        res = await ut.minSourceNum.call();
        assert.equal(res, minSourceNum, "equal");

        await ut.setIsRemoveMaxMin(false, {from:operator_1});
        res = await ut.isRemoveMaxMin.call();
        assert.equal(res, false, "equal");

        await ut.setMinRecordNum(minRecordNum, {from:operator_1});
        res = await ut.minRecordNum.call();
        assert.equal(res, minRecordNum, "equal");
  });


  it("admin set value",async () =>  {
        const ut = await USDTTC.deployed();
        await ut.setValue(145, {from:operator_1});
        await ut.setValue(146, {from:operator_2});
        await ut.setValue(153, {from:operator_3});

        res = await ut.getLatestValue.call();
        console.log("res =>",res);
        //assert.equal((145+146+153)/3, res, "equal");
        
  });
});
