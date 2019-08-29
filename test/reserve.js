var Reserve = artifacts.require("./Reserve.sol");
var CLAY = artifacts.require("./CLAY.sol");

contract('Reserve', function() {
	var eth = web3.eth;
  	var owner = eth.accounts[0];

  	var CLAYReserveAddress = "0x018043e33dab6434d22c998c43f1dff47fbbccbf";
 // pk = 52b9b455143c8fbb1a8e9ef3e2452a24bb196c86efc8a44f69fc7ad9ccced823
 	var user = '0x48449ccfb77fc86707c9757009ca7be343902e3f';
 	//pk = a9e9cb65e35cf7a52a13b285b3eb54cda5a5a04c6cf47dd18e38637533d10f28

  	var initalCLAYReserve = 1000000000 * 10 **18;

	it("get admin ",async () =>  {
        const reserve = await Reserve.deployed();
        admin = await reserve.admin.call()
        assert.equal(admin, owner, "equal")
    });

    it("admin set operator  ",async () =>  {
        const reserve = await Reserve.deployed();
        await reserve.addOperator(owner, {from:owner});
        operator = await reserve.getOperators.call();
        assert.equal(operator[0], owner, "equal");
    });

  	it("reserve", async () =>{
  		const clay = await CLAY.deployed();
  		const reserve = await Reserve.deployed();
  		clay.transfer(CLAYReserveAddress,initalCLAYReserve,{from:owner});
  		var CLAYReserve = await clay.balanceOf.call(CLAYReserveAddress);
		assert.equal(CLAYReserve, initalCLAYReserve, "equal")

  	});	

  	it("operator clay addr", async () =>{
  		const clay = await CLAY.deployed();
  		const reserve = await Reserve.deployed();
  		reserve.setCLAYAddress(clay.address,{from:owner})
  		const token = await reserve.getCLAYAddress.call();
  		assert.equal(token, clay.address, "equal")
		
  	});	


  	it("operator setCLAYDrawAddress", async () =>{
  		const reserve = await Reserve.deployed();
  		reserve.setCLAYDrawAddress(CLAYReserveAddress,{from:owner})
  		clayReserveAddr= await reserve.CLAYReserveAddress.call();
  		assert.equal(clayReserveAddr, CLAYReserveAddress, "equal")
		
  	});

  	it("operator set TTC reserve", async () =>{
  		const clay = await CLAY.deployed();
  		const reserve = await Reserve.deployed();
  		reserve.setTTCReserve(1000000000000000000000000000,{from:owner})
  		balance = await reserve.getTotalReserve.call();
		assert.equal(balance[0], 1000000000000000000000000000, "equal")
		assert.equal(balance[1], 1000000000000000000000000000, "equal")
  	});	

  	it("operator set TTC reserve", async () =>{
  		const clay = await CLAY.deployed();
  		const reserve = await Reserve.deployed();
  		reserve.setTTCReserve(1000000000000000000000000000,{from:owner})
  		balance = await reserve.getTotalReserve.call();
		assert.equal(balance[0], 1000000000000000000000000000, "equal")
		assert.equal(balance[1], 1000000000000000000000000000, "equal")
  	});

  	it("operator setMonthlyMaintainPercent", async () =>{
  		const clay = await CLAY.deployed();
  		const reserve = await Reserve.deployed();
  		reserve.setMonthlyMaintainPercent(3,21,{from:owner})
  		MonthlyPercent = await reserve.lastMonthlyPercent.call();
  		GrowthPercent = await reserve.monthlyGrowthPercent.call();
  		assert.equal(MonthlyPercent, 3, "equal")
		assert.equal(GrowthPercent, 21, "equal")
  	});

  	it("monthlyMaintain", async () =>{
  		const clay = await CLAY.deployed();
  		const reserve = await Reserve.deployed();
  		monthlyServiceFee = await reserve.monthlyMaintain.call(1000800000000000000000000000,800000000000000000000000);
  		console.log(monthlyServiceFee)
  		assert.equal(monthlyServiceFee,30192000000000000000000000, "equal")
  	});


});



















