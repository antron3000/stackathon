pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;


contract BettingSystem {
    struct Match {
        mapping(address => int) positions;
        address[] bettorList;
        uint totalAmount;
        bool finalized;
    }

    mapping(bytes32 => Match) matches;



    function bet(bytes32 matchId, bool _for) payable public {


        matches[matchId].positions[msg.sender] = int(_for ? msg.value : -msg.value);
        matches[matchId].bettorList.push(msg.sender);
        matches[matchId].totalAmount += msg.value;
    }

    function claim(bytes32 witness, uint256 graderQuorum, address[] memory graders, uint8 finalPrice, bytes32[][] memory sigs) public {
        require(finalPrice <= 100);

        bytes32 matchId = keccak256(abi.encodePacked(witness, graderQuorum, graders));
        bytes32 messageHash = keccak256(abi.encodePacked(matchId, finalPrice)); // FIXME: should use contract addr to prevent replay attacks
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

        uint toWithdraw = matches[matchId].totalAmount/matches[matchId].bettorList.length;
        matches[matchId].positions[msg.sender] = 0;
        msg.sender.transfer(toWithdraw);
    }

    function recoverFunds(uint256 graderQuorum, address[] memory graders, bytes32 detailsHash, uint recoveryTime, uint8 cancelPrice) public {
        bytes32 witness = keccak256(abi.encodePacked(detailsHash, recoveryTime, cancelPrice));
        bytes32 matchId = keccak256(abi.encodePacked(witness, graderQuorum, graders));

        require(recoveryTime < block.timestamp);

        // finalize matchId at cancelPrice
        matches[matchId].finalized = true;
    }
}
