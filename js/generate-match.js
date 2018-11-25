"use strict";

const ethUtil = require("ethereumjs-util");
const BigNumber = require('bignumber.js');



/*
    private: 0365be60d95dd5e774443196adf523bf1811aaaccae0be83b43ce5fa9458eae5
    address: 4176350697d42bc937616ce18001f50c8a751b54

    private: 3e86c5e33748a44f77fe4ba36d3d55c566ddc546f8a761c13353fdb18bdee743
    address: 01a346af3a7217957546d772d2fa20ece9880b3b

    private: 8f05848fc6b9a68382785f2088f18bf60f6f8b497806122c2be25ac348ac9ee8
    address: e6ec4579be32f1f6a22a22a58fdf063677b13d98




input:
*/

let input = {
  cancelPrice: 50,
  recoveryTime: 1543207976,
  graderQuorum: 2,
  graders: ['4176350697d42bc937616ce18001f50c8a751b54', '01a346af3a7217957546d772d2fa20ece9880b3b', 'e6ec4579be32f1f6a22a22a58fdf063677b13d98'],
  details: {
    sport: 'nfl',
    team1: 'Buffalo Bills',
    team2: 'New England Patriots',
  },
};


console.log(computeMatchId(input));



function computeMatchId(match) {
    let ordered = {};
    Object.keys(match).sort().forEach((key) => {
        ordered[key] = match[key];
    });

    let detailsHash = ethUtil.keccak256(new Buffer(JSON.stringify(ordered))).toString('hex');
    let witness = ethUtil.keccak256(new Buffer(normalizeComponent(detailsHash, 256) + normalizeComponent(match.recoveryTime, 256) + normalizeComponent(match.cancelPrice, 8), 'hex')).toString('hex');

    let graderAddresses = '';
    match.graders.forEach(g => graderAddresses += normalizeComponent(g, 160));
    let matchId = ethUtil.keccak256(new Buffer(normalizeComponent(witness, 256) + normalizeComponent(match.graderQuorum, 256) + graderAddresses, 'hex'));

    return {
      detailsHash,
      witness,
      matchId: matchId.toString('hex'),
    };
}



function normalizeComponent(inp, bits) {
    if (inp instanceof Buffer) inp = inp.toString('hex');
    else if (typeof(inp) === 'number') inp = (new BigNumber(inp)).toString(16);
    else if (typeof(inp) === 'string') {}
    else if (typeof(inp) === 'object' && inp.isBigNumber) inp = inp.toString(16);
    else throw("unexpected type: " + typeof(inp));

    if (inp.substring(0, 2) === '0x') inp = inp.substring(2);
    inp = "0".repeat(Math.max(0, (bits/4) - inp.length)) + inp;

    if (inp.length > (bits/4)) throw("input too long");

    return inp;
}
