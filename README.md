# Tigris

A Secure And Efficient Decentralized Financial Solution Based On the TTC Platform

The Tigris protocol is a protocol for an improved and much more efficient DeFi services (“Tigris Protocol”). The Tigris Protocol derives its name from the Tigris river, where ancient Babylon civilization was born. Babylonians used clay tablets to keep transaction records. It was one of the earliest ledger forms in human history.

The Tigris Protocol includes a Collateral Debt Service (“CDS”), TTC Staking Service (“TSS”), the Tigris Reward Program, and the Tigris Debit Card (physical payment card), all of which closely interact with a set of stablecoins “CFIAT”.

More Details about Tigris could be found on [Tigris Whitepaper](https://ttceco.github.io/Tigris_Whitepaper_EN.pdf)

## Developer Resources

* The Tigris smart contract list:

  * [CDS](https://github.com/TTCECO/Tigris/blob/master/contracts/CDS.sol) - CDS provides collateralized debt service and TTC staking service. 
  * [CDSDatabase](https://github.com/TTCECO/Tigris/blob/master/contracts/CDSDatabase.sol) - Database of CDS
  * [Oracle](https://github.com/TTCECO/Tigris/blob/master/contracts/Oracle.sol) - Access data from outside of TTC network. 
  * [CFIAT](https://github.com/TTCECO/Tigris/blob/master/contracts/CFIAT.sol) - A series of decentralized TST-20 stablecoins issued.
on the TTC platform 

## How to test

To run tests you need to install the following software:

- [Truffle v3.2.4](https://github.com/trufflesuite/truffle-core)
- [EthereumJS TestRPC v3.0.5](https://github.com/ethereumjs/testrpc)

To run test open the terminal and run the following commnds:

```sh
$ cd Tigris
$ truffle migrate
$ truffle test 

```

## License

Tigris smart contract is licensed under the [GNU General Public License v3.0](https://github.com/TTCECO/Tigris/blob/master/LICENSE)
