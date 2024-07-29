// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Voting {
    enum Choice {no, yes}
    struct Vote {
        address voter;
        Choice choice;
    }
    Vote [] public votes;
    mapping(address => uint) count;
    Vote none = Vote(address(0), Choice(0));
    // Voters can make their first vote
    function VoteChoice(Choice _choice) external {
        require(!hasMadeVote(msg.sender), "You can only vote once");
        votes.push(Vote(msg.sender, _choice));
    }
    function findVote(address voter) internal view returns(Vote storage) {
        for(uint i = 0; i < votes.length; i++){
            if(votes[i].voter == voter){
                return votes[i];
            }
        }
        return none;
    }
    // verifying if a voter made a choice
    function hasMadeVote(address voter) public view returns(bool){
        return findVote(voter).voter == voter;
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