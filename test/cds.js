var CUSD = artifacts.require("./CFIAT.sol");
var CDS = artifacts.require("./CDS.sol");
var VOTE_REWARD = artifacts.require("./ORACLE.sol");
var CLAY = artifacts.require("./CLAY.sol");

contract('CDS', function() {
	var eth = web3.eth;
  var owner = eth.accounts[0];
  var operator_1 = eth.accounts[1];
  var buyer_1 = eth.accounts[2];
  var buyer_2 = eth.accounts[3];


	it("get admin ",async () =>  {
        const cds = await CDS.deployed();
        admin = await cds.admin.call()
        assert.equal(admin, owner, "equal")
  });

  it("admin set operator  ",async () =>  {
        const cds = await CDS.deployed();
        await cds.addOperator(operator_1, {from:owner});

        const vote_reward = await VOTE_REWARD.deployed();
        await vote_reward.addOperator(operator_1, {from:owner});

        operator = await cds.getOperators.call();
        assert.equal(operator[0], operator_1, "equal");

        operator = await vote_reward.getOperators.call();
        assert.equal(operator[0], operator_1, "equal");
  });

  it("admin add token",async () =>  {
        const cds = await CDS.deployed();
        const clay = await CLAY.deployed();
        await cds.addAcceptCollateralToken(clay.address,"CLAY", {from:owner});
        accept = await cds.isAcceptCollateralToken.call(clay.address);
        assert.equal(accept, "CLAY", "equal");

        await cds.addAcceptCollateralToken(clay.address,"TokenFake", {from:owner});
        accept = await cds.isAcceptCollateralToken.call(clay.address);
        assert.equal(accept, "CLAY", "equal");
  });


  it("cds set oracle vote_reward",async () =>  { 
        const cds = await CDS.deployed();
        const vote_reward = await VOTE_REWARD.deployed();
        await cds.setVoteReward(vote_reward.address,{from:owner});
        await vote_reward.setValidDistance(30, {from:operator_1});
        blockNumber = await web3.eth.blockNumber + 5; // next 3 txs 
        
        vote_reward.setValue(145, {from:operator_1});
        vote_reward.setValue(146, {from:operator_1});
        vote_reward.setValue(153, {from:operator_1});

        res = await vote_reward.getValue.call(blockNumber);
        assert.equal((145+146+153)/3, res, "equal");


  });


  it("deposit TTC",async () =>  {
        var TTC_VALUE = 1 * 10 ** 18;
        const cds = await CDS.deployed();
        var denominator =10000;


        await web3.eth.sendTransaction({from: buyer_1, to: cds.address, value: TTC_VALUE, gas:200000});

        res = await cds.collateralTTC.call(buyer_1);
        assert.equal(res[1], TTC_VALUE);

        await web3.eth.sendTransaction({from: buyer_2, to: cds.address, value: TTC_VALUE, gas:200000});
        res = await cds.collateralTTC.call(buyer_2);
        assert.equal(res[1], TTC_VALUE);


        await web3.eth.sendTransaction({from: buyer_1, to: cds.address, value: TTC_VALUE, gas:200000});
        res = await cds.collateralTTC.call(buyer_1);
        assert.equal(res[1], TTC_VALUE + TTC_VALUE * ((145+146+153)/3 + denominator)/denominator );

  });

});



















