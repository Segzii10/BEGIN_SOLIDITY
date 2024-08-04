// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Voting {
    enum Choice {no, yes}
    struct Vote {
        address voter;
        Choice choice;
    }
    Vote [] public votes;
    mapping(address => uint) private count;
    // mapping address to know if they voted or not
    mapping(address => bool) private voted;
    // Voters can make their first vote
    function VoteChoice(Choice _choice) external {
        require(!hasMadeVote(msg.sender), "You can only vote once");
        votes.push(Vote({
            voter : msg.sender,
            choice : _choice
        }));
        voted[msg.sender] = true;
    }
    
    // verifying if a voter made a choice
    function hasMadeVote(address voter) public view returns(bool){
        return voted[voter];
    }
    // voters can change their vote
    function changeVote(uint id, Choice _choice) external {
        Vote storage vote = votes[id];
        require(id < votes.length, "invalid length");
        count[vote.voter]++;
        require(count[vote.voter] == 1, "you can only change your vote once");
        vote.choice = _choice;
    }
}