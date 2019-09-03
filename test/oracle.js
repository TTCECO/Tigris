var USDTTC = artifacts.require("./ORACLE.sol");

contract('ORACLE', function() {
	var eth = web3.eth;
  var owner = eth.accounts[0];

  var CLAYReserveAddress = "0x018043e33dab6434d22c998c43f1dff47fbbccbf";
  // pk = 52b9b455143c8fbb1a8e9ef3e2452a24bb196c86efc8a44f69fc7ad9ccced823
 	var user = '0x48449ccfb77fc86707c9757009ca7be343902e3f';
 	//pk = a9e9cb65e35cf7a52a13b285b3eb54cda5a5a04c6cf47dd18e38637533d10f28

  var initalCUSD = 0 * 10 **18;

	it("get admin",async () =>  {
        const cusd = await USDTTC.deployed();
        admin = await cusd.admin.call()
        assert.equal(admin, owner, "equal")
  });

  it("admin set operator",async () =>  {
        const cusd = await USDTTC.deployed();
        await cusd.addOperator(owner, {from:owner});
        operator = await cusd.getOperators.call();
        assert.equal(operator[0], owner, "equal");
  });


});
