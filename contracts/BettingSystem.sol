pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

//todo calculate payouts properly
//re-bet
//display json data

contract BettingSystem {
    struct Match {
        mapping(address => int) positions;
        uint betsfor;
        mapping(bool=>uint) numBets;
        bool finalized;
        uint totalAmount;
    }

    mapping(bytes32 => Match) public bets;


    function bet(bytes32 matchId, bool _for) payable public {
        require(msg.value >0);
        require(bets[matchId].positions[msg.sender]==0);
        require(bets[matchId].finalized==false);
        bets[matchId].positions[msg.sender] = int(_for ? msg.value : -msg.value);
        bets[matchId].numBets[_for]+=1;
        bets[matchId].totalAmount += msg.value;
    }

    function claim(bytes32 witness, uint256 graderQuorum, address[] memory graders, uint8 finalPrice, bytes32[3][] memory sigs) public {
        require(finalPrice <= 100);
        require(sigs[0].length == graders.length, "insufficient signatures passed in");


        bytes32 matchId = keccak256(abi.encodePacked(witness, graderQuorum, graders[0], graders[1], graders[2])); // figure out ABI encoding
        require(bets[matchId].positions[msg.sender]!= 0);
        bytes32 messageHash = keccak256(abi.encodePacked(matchId, finalPrice)); // FIXME: should use contract addr to prevent replay attacks
        bytes32 messageHash2 = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));

        uint256 validated = 0;

        for (uint i = 0; i < graders.length; i++) {
            if (sigs[i][0] != 0) {
                bytes32 r = sigs[i][0];
                bytes32 s = sigs[i][1];
                uint8 v = uint8(sigs[i][2][31]);
                address signer = ecrecover(messageHash2, v, r, s);
                require(signer == graders[i], "bad grader signature");
                validated++;
            }
        }

        require(validated >= graderQuorum, "insufficient graders for quorum");
        uint toWithdraw;
        if(bets[matchId].positions[msg.sender]> 0){
             toWithdraw = (finalPrice*bets[matchId].totalAmount / bets[matchId].numBets[true])/100;
        } else {
             toWithdraw = ((100-finalPrice)*bets[matchId].totalAmount / bets[matchId].numBets[false])/100;
        }
        bets[matchId].positions[msg.sender] = 0;
        msg.sender.transfer(toWithdraw);
    }



    function recoverFunds(uint256 graderQuorum, address[] memory graders, bytes32 detailsHash, uint recoveryTime, uint8 cancelPrice) public {
        bytes32 witness = keccak256(abi.encodePacked(detailsHash, recoveryTime, cancelPrice));
        bytes32 matchId = keccak256(abi.encodePacked(witness, graderQuorum, graders));

        require(recoveryTime < block.timestamp);

        // finalize matchId at cancelPrice
        bets[matchId].finalized = true;
    }
}
