pragma solidity ^0.5.0;
//pragma experimental ABIEncoderV2;


contract BettingSystem {
    function claim(uint witness, uint graderQuorum, address[] memory graders, uint8 finalPrice, bytes32[][3] memory sigs) public {
        require(finalPrice <= 100);

        uint matchId = keccak256(abi.encodePacked(witness, graderQuorum, graders));
        uint messageHash = keccak256(abi.encodePacked(this, matchId, finalPrice));
        uint messageHash2 = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", messageHash));

        uint validated = 0;

        for (uint i = 0; i < graders.length; i++) {
            if (sigs[i][0] != 0) {
                address signer = ecrecover(messageHash2, sigs[i][2], sigs[i][0], sigs[i][1]);
                require(signer == graders[i], "bad grader signature");
                validated++;
            }
        }

        require(validated >= graderQuorum, "insufficient graders for quorum");
    }
}
