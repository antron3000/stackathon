"use strict";

const ethUtil = require("ethereumjs-util");
const BigNumber = require('bignumber.js');

function signWithPrivateKey(msg, privateKey) {
    let msgHash = ethUtil.keccak256(Buffer.concat([
        new Buffer("\x19Ethereum Signed Message:\n" + msg.length),
        msg,
    ]));

    let sig = ethUtil.ecsign(msgHash, new Buffer(privateKey, 'hex'));
    sig.r = sig.r.toString('hex');
    sig.s = sig.s.toString('hex');
    sig.v = normalizeComponent(sig.v, 8);

    return sig;
}


function buildFinalizationMessage(privateKey, matchId, finalPrice) {
    let details = {
        matchId: normalizeComponent(matchId, 256),
        finalPrice: normalizeComponent(finalPrice, 8),
    };

    let raw = [
        details.contractAddr,
        details.matchId,
        details.finalPrice,
    ].join('');

    let sig = signWithPrivateKey(ethUtil.keccak256(new Buffer(raw, 'hex')), privateKey);

    return sig;
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





let privateKey = process.argv[2];
let matchId = process.argv[3];
let finalPrice = process.argv[4];

console.log(JSON.stringify(buildFinalizationMessage(privateKey, matchId, finalPrice)));
