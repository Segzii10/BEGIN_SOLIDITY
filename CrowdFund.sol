// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
/*
This is a campaign
a token created by the owner 
of this contract
others are meant to
pledge their tokens to this contract
*/

import "./ERC20.sol";

contract CrowdFund{

    event Launch(address indexed owner, uint indexed goal, uint duration);
    event Cancel(uint id);
    event unpledged(address owners, uint id, uint amount);
    event Claim(address owner, uint id, uint amountClaimed);
    event Pledge(address campaigners, uint amount);
    event Refund(address owners, uint amount);

    struct Campaign {
        address creator;
        uint goal;
        uint pledge;
        uint32 campaignStartTime;
        uint32 campaignEndTime;
        bool claimed;
    }
    IERC20 public token;
    uint public count;
    mapping(uint => Campaign) public campaign;
    mapping(uint => mapping(address => uint)) public pledges;
    // one time to initialize ERC20 token
    constructor(address _token) {
        token = IERC20(_token);
    }
    // function to launch a token of ERC20
    function launch(uint _goal, uint _duration) external {
        count += 1;
        campaign[count] = Campaign({
            creator : msg.sender,
            goal : _goal,
            pledge : 0,
            campaignStartTime: uint32(block.timestamp),
            campaignEndTime: uint32(block.timestamp + _duration),
            claimed: false
        });
        emit Launch(msg.sender, _goal, campaign[count].campaignEndTime);
    }
    // function to cancel the campaign before started 
    function cancel(uint _id) external {
        Campaign memory campaigns = campaign[_id];
        require(campaigns.creator == msg.sender, "only creator can cancel");
        require(block.timestamp < campaigns.campaignStartTime, "started already");
        require(block.timestamp < campaigns.campaignEndTime, "Ended already");
        delete campaign[_id];
        //emit Cancel(uint _id);
    }
    // function to pledge some amount of tokens to this contract for this campaign
    function pledge(uint _id, uint amount) external {
        Campaign storage campaigns = campaign[_id];
        require(block.timestamp >= campaigns.campaignStartTime, "not started yet");
        require(block.timestamp < campaigns.campaignEndTime, "Ended already");
        require(amount > 0, "greater than 0");
        campaigns.pledge += amount;
        pledges[_id][msg.sender] += amount;
        token.transferFrom(msg.sender, address(this), amount);
        emit Pledge(msg.sender, amount);
    }
    // function to unpledge the amount of tokens pledged in this contract
    function Unpledge(uint _id, uint amount) external {
        Campaign storage campaigns = campaign[_id];
        require(block.timestamp >= campaigns.campaignStartTime, "not started yet");
        require(block.timestamp < campaigns.campaignEndTime, "Ended already");
        require(!campaigns.claimed, "claimed already");

        campaigns.pledge -= amount;
        pledges[_id][msg.sender] -= amount;
        token.transfer(msg.sender, amount);
        emit unpledged(msg.sender, _id, amount);
    }
    //Only the creator can claim this token
    //Creator can only claim if the campaign has already ended
    function claim(uint _id) external {
        Campaign storage campaigns = campaign[_id];
        require(campaigns.creator == msg.sender, "only creator of token can claim");
        require(block.timestamp >= campaigns.campaignEndTime, "campaign not ended yet");
        require(campaigns.pledge >= campaigns.goal, "pledges less than the goal");
        require(!campaigns.claimed, "claimed already");

        campaigns.claimed = true;
        token.transfer(msg.sender, campaigns.pledge);
        emit Claim(msg.sender, _id, campaigns.pledge);
    }
    // function to refund the pledgers
    // only refund 
    function refund(uint _id) external {
        uint balance = pledges[_id][msg.sender];
        require(balance > 0, "No pledge to withdraw");
        pledges[_id][msg.sender] = 0;
        token.transfer(msg.sender, balance);
        emit Refund(msg.sender, balance);
    }
    // function to check the timeleft 
    function timeLeft(uint _id) external view returns(uint32) {
        Campaign memory campaigns = campaign[_id];
        return campaigns.campaignEndTime -  uint32(block.timestamp);
    }
}
