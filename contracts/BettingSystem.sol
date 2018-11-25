pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;


contract BettingSystem {
    struct Bet{
        mapping(address => int) positions;
        address[] bettorList;
        uint totalAmount;
    }

    mapping(bytes32 => Bet) bets;


    function bet(bytes32 matchId, bool _for) payable public {
        bets[matchId].positions[msg.sender] = int(_for ? msg.value : -msg.value);
        bets[matchId].bettorList.push(msg.sender);
        bets[matchId].totalAmount += msg.value;
    }

    function claim(bytes32 witness, uint256 graderQuorum, address[] memory graders, uint8 finalPrice, bytes32[][3] memory sigs) public {
        require(finalPrice <= 100);

        bytes32 matchId = keccak256(abi.encodePacked(witness, graderQuorum, graders));
        bytes32 messageHash = keccak256(abi.encodePacked(this, matchId, finalPrice));
        bytes32 messageHash2 = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));

        uint256 validated = 0;

        for (uint i = 0; i < graders.length; i++) {
            if (sigs[i][0] != 0) {
                address signer = ecrecover(messageHash2, uint8(sigs[i][2][0]), sigs[i][0], sigs[i][1]);
                require(signer == graders[i], "bad grader signature");
                validated++;
            }
        }

        require(validated >= graderQuorum, "insufficient graders for quorum");

        uint toWithdraw = bets[matchId].totalAmount/bets[matchId].bettorList.length;
        bets[matchId].positions[msg.sender] = 0;
        msg.sender.transfer(toWithdraw);
    }

    //function recoverFunds(bytes32 witness, uint256 graderQuorum, address[] memory graders, bytes32 detailsHash, uint recoveryTime, uint8 cancelPrice) public {
    //}
}
