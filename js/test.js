"use strict";

const ethers = require('ethers');
const ganacheCli = require('ganache-cli');

const bettingSystemSpec = require('../contracts/build/BettingSystem.json');
const bettingSystemAbi = JSON.parse(bettingSystemSpec.contracts['BettingSystem.sol:BettingSystem'].abi);
const bettingSystemBin = bettingSystemSpec.contracts['BettingSystem.sol:BettingSystem'].bin;


async function doTest() {
    let ethProvider = new ethers.providers.Web3Provider(ganacheCli.provider());

    let factory = new ethers.ContractFactory(bettingSystemAbi, bettingSystemBin, ethProvider.getSigner(0));
    let contract = await factory.deploy();

    contract.claim('0xac6349cadc1d26022729135f6e2e0d6486ad76a3ffcf219df65a6d8c9d41a117', 2, ['0x4176350697d42bc937616ce18001f50c8a751b54', '0x01a346af3a7217957546d772d2fa20ece9880b3b', '0xe6ec4579be32f1f6a22a22a58fdf063677b13d98'], 0, [

["0x78c26eafcdf1106a9a77352e92d82790128239eee71a5b5aa5585ec52ec6def6","0x21f76375ff700bed287e304d5606c20c32889aea9573259b723f828626682414","0x000000000000000000000000000000000000000000000000000000000000001b"],
["0xffa192c01952dcbf032e094acaa1ad7c9375d5a4f78b6ebb5c9e359da21a8278","0x11843d922ab134563551933bb157939db308ed4800ff04f2b78e16fc0ddb6e32","0x000000000000000000000000000000000000000000000000000000000000001c"],
["0x0000000000000000000000000000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000000000000000000000000000","0x0000000000000000000000000000000000000000000000000000000000000000"]

]);

/*
    console.log(contract.address);

    let accounts = await ethProvider.listAccounts();
    console.log(accounts);
*/
}

doTest();
