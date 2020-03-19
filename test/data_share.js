var DS = artifacts.require("./DataShare.sol");


contract('DS', function() {
  var eth = web3.eth;
  var owner = eth.accounts[0];
  var operator_1 = eth.accounts[1];
  var operator_2 = eth.accounts[2];

  it("get admin",async () =>  {
        const ds = await DS.deployed();
        admin = await ds.admin.call()
        assert.equal(admin, owner, "equal")

  });

  it("admin set operator",async () =>  {
        const ds = await DS.deployed();
        await ds.addOperator(operator_1, {from:owner});
        await ds.addOperator(operator_2, {from:owner});
        operators = await ds.getOperators.call();
        assert.equal(operators[0], operator_1, "equal");
        assert.equal(operators[1], operator_2, "equal");

  });

  it("add & zip ",async () =>  {
        contractName = "my_test";
        addValue = 100;

        const ds = await DS.deployed();
        await ds.setName(contractName, {from:owner});
        name = await ds.name.call();
        assert.equal(contractName, name, "equal");

        await ds.addData(addValue, {from:operator_1});
        res = await ds.curData.call();
        assert.equal(res, addValue, "equal");

        await ds.addData(addValue*2, {from:operator_1});
        res = await ds.curData.call();
        assert.equal(res, addValue*3, "equal");

        await ds.zipData({from:operator_1});
        res = await ds.curData.call();
        assert.equal(res, 0, "equal");

  });

});
