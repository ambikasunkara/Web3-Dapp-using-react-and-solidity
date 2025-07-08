// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Voting {
    address public admin;
    uint public electionEndTime;
    bool public electionStarted;

    struct Candidate {
        string name;
        uint voteCount;
    }

    mapping(address => bool) public hasVoted;
    Candidate[] public candidates;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can do this.");
        _;
    }

    modifier electionActive() {
        require(electionStarted, "Election not started.");
        require(block.timestamp < electionEndTime, "Election ended.");
        _;
    }

    function startElection(string[] memory candidateNames, uint durationInMinutes) public onlyAdmin {
        require(!electionStarted, "Election already started.");

        for (uint i = 0; i < candidateNames.length; i++) {
            candidates.push(Candidate(candidateNames[i], 0));
        }

        electionEndTime = block.timestamp + (durationInMinutes * 1 minutes);
        electionStarted = true;
    }

    function vote(uint candidateIndex) public electionActive {
        require(!hasVoted[msg.sender], "You have already voted.");
        require(candidateIndex < candidates.length, "Invalid candidate index.");

        candidates[candidateIndex].voteCount++;
        hasVoted[msg.sender] = true;
    }

    function getRemainingTime() public view returns (uint) {
        if (block.timestamp >= electionEndTime) return 0;
        return electionEndTime - block.timestamp;
    }

    function getAllVotesOfCandidates() public view returns (Candidate[] memory) {
        require(electionStarted, "Election has not started yet.");
        return candidates;
    }

    function getCandidateCount() public view returns (uint) {
        return candidates.length;
    }

    function hasUserVoted(address user) public view returns (bool) {
        return hasVoted[user];
    }
}
