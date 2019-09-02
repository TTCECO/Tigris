var CUSD = artifacts.require("./CFIAT.sol");

contract('CFIAT', function() {
	var eth = web3.eth;
  var owner = eth.accounts[0];
  var operator_1 = eth.accounts[1];
  var user_1 = eth.accounts[2];
  var user_2 = eth.accounts[3];
  var usd_value = 99 * 10 **18;

	it("check admin",async () =>  {
        const cusd = await CUSD.deployed();
        admin = await cusd.admin.call()
        assert.equal(admin, owner, "equal")
  });

  it("admin add operators & check",async () =>  {
        const cusd = await CUSD.deployed();
        await cusd.addOperator(operator_1, {from:owner});
        operators = await cusd.getOperators.call();
        assert.equal(operators[0], operator_1, "equal");
  });

  it("check init total supply, should be zero", async () =>{
  		const cusd = await CUSD.deployed();
  		var totalSupply = await cusd.totalSupply.call();
		  assert.equal(totalSupply, 0, "equal")
  });	


  it("create cusd for address by not operator",function(){
    return CUSD.deployed().then(function(cusd) {
        return cusd.create(user_1, usd_value, {from:user_1});
     }).catch(function(error) {
        assert(error.toString().includes('Error: VM Exception while processing transaction: revert'), error.toString())
    });

  });


  it("create cusd for user_1 by operator", async () =>{
      const cusd = await CUSD.deployed();
      await cusd.create(user_1, usd_value, {from:operator_1});
      var user_1_cusd = await cusd.balanceOf.call(user_1);
      assert.equal(user_1_cusd, usd_value, "equal")
      var totalSupply = await cusd.totalSupply.call();
      assert.equal(totalSupply, usd_value, "equal")
  }); 


  it("create cusd for user_2 by operator", async () =>{
      const cusd = await CUSD.deployed();
      await cusd.create(user_2, usd_value * 2, {from:operator_1});
      var user_2_cusd = await cusd.balanceOf.call(user_2);
      assert.equal(user_2_cusd, usd_value * 2, "equal")
      var totalSupply = await cusd.totalSupply.call();
      assert.equal(totalSupply, usd_value * 3, "equal")
  }); 


  it("burn cusd for user_2 by operator", async () =>{
      const cusd = await CUSD.deployed();
      await cusd.burn(user_2, usd_value , {from:operator_1});
      var user_2_cusd = await cusd.balanceOf.call(user_2);
      assert.equal(user_2_cusd, usd_value, "equal")
      var totalSupply = await cusd.totalSupply.call();
      assert.equal(totalSupply, usd_value * 2, "equal")
  }); 

  it("burn cusd for user_1 by operator", async () =>{
      const cusd = await CUSD.deployed();
      await cusd.burn(user_1, usd_value , {from:operator_1});
      var user_1_cusd = await cusd.balanceOf.call(user_1);
      assert.equal(user_1_cusd, 0, "equal")
      var totalSupply = await cusd.totalSupply.call();
      assert.equal(totalSupply, usd_value , "equal")
  }); 

  it("burn cusd for address by operator, when not enough value to burn",function(){
    return CUSD.deployed().then(function(cusd) {
        return cusd.burn(user_2, usd_value * 2, {from:operator_1});
     }).catch(function(error) {
        assert(error.toString().includes('Error: VM Exception while processing transaction: revert'), error.toString())
      async () => {

        var user_2_cusd = await cusd.balanceOf.call(user_2);
        assert.equal(user_2_cusd, usd_value, "equal")
        var totalSupply = await cusd.totalSupply.call();
        assert.equal(totalSupply, usd_value , "equal")

      }
    });
  });

  it("claimToken by admin", async () =>{
      const cusd = await CUSD.deployed();
      ownerBalance = await web3.eth.getBalance(owner);
      await cusd.sendTransaction({from: owner, to: cusd.address, value:10000});
      await cusd.transfer(cusd.address,usd_value,{from:user_2});
      await cusd.claimToken(cusd.address , {from:owner});
      
      var owner_cusd = await cusd.balanceOf.call(owner);
      assert.equal(owner_cusd, usd_value, "equal")
      var totalSupply = await cusd.totalSupply.call();
      assert.equal(totalSupply, usd_value , "equal")
      
  }); 


});
