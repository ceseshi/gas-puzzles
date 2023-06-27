// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.15;

contract OptimizedVote {

    /// Changed uint8 to uint248 to fill a 32 bytes word, which saves execution steps when writing to storage
    struct Voter {
        uint248 vote;
        bool voted;
    }

    /// Changed uint8 to uint256, also less execution steps when writing
    struct Proposal {
        uint256 voteCount;
        bytes32 name;
        bool ended;
    }

    mapping(address => Voter) public voters;

    // Changed the array to a mapping, more efficient as we don't need to iterate
    mapping(uint256 => Proposal) proposals;
    uint256 proposalsLength;

    /// Write only non-zero values to storage
    function createProposal(bytes32 _name) external {
        proposals[proposalsLength].name = _name;

        /// This won't overflow
        unchecked {
            proposalsLength += 1;
        }
    }

    function vote(uint8 _proposal) external {
        require(!voters[msg.sender].voted, 'already voted');

        voters[msg.sender].vote = _proposal;
        voters[msg.sender].voted = true;

        /// This won't overflow
        unchecked {
            proposals[_proposal].voteCount += 1;
        }
    }

    function getVoteCount(uint8 _proposal) external view returns (uint8) {
        return uint8(proposals[_proposal].voteCount);
    }
}