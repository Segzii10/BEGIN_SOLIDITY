// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./ERC20.sol";

contract FundToken {
    error NothingPledged();
    /**
      * @dev This contract gets token as contribution 
             to execute a particular transaction well
             known by the community
    **/

      // emitted when an address launch a campaign
    event Launch(address indexed owner, uint indexed goal, uint duration);
    // emitted when the creator cancel the campaign before it is launch
    event Cancel(uint id);
    // emitted when an address unpledge token from the contract
    event unpledged(address owners, uint id, uint amount);
    // emitted when the creator claimed the tokens
    event Claim(address owner, uint id, uint amountClaimed);
    // emitted when some tokens are pledged to this contract
    event Pledge(address campaigners, uint amount);
    // if the amount pledged to this contract doesnt reach the required goal
    // address can get a refund
    event Refund(address owners, uint amount);

    struct Campaign {
        /** 
          * a struct needed for the campaign
          * All details needed for the campaign
          * to be executed
        **/
        address CreatorOfCampaign;
        uint goal;
        uint Amountpledge;
        uint Starttime;
        uint duration;
        uint finishedtime;
        bool claimed;
    }
    
    mapping(uint => Campaign) public campaigns;
    // get amountpledge by users
    mapping(uint => mapping(address => uint)) public AmountpledgedbyUser;
    // updating the numbers of campaigns
    uint public  count;
    // ERC20 token to be implemented
    IERC20 public immutable Token;

    constructor(address _token) {
        Token = IERC20(_token);
    }

    modifier idExist(uint id) {
        require(id == count, "doesnt exist");
        _;
    }
    modifier pledgingAmount(uint _amount) {
        require(_amount > 0, "invalid amount");
        _;
    }
    

    function launchCampaign(uint _goal, uint _duration) external  {
        /**
          * Only deployer of this contract can launch campaign
        **/
        count += 1;
        campaigns[count] = Campaign({
            CreatorOfCampaign : msg.sender,
            goal : _goal,
            Amountpledge : 0,
            Starttime : block.timestamp,
            duration : _duration,
            finishedtime : block.timestamp + _duration,
            claimed : false

        });
        emit Launch(msg.sender, _goal, _duration);
    }
    function cancelCampaign(uint id) external idExist(id) {
        /**
          * Campaign can be cancelled by deployer of this contract
          * immediately the campaign is deleted
        **/
        Campaign memory campaign = campaigns[id];
        require(campaign.CreatorOfCampaign == msg.sender, "Not owner");
        require(block.timestamp < campaign.Starttime, "started already");
        require(!campaign.claimed, "claimed already");

        delete campaigns[id];
        emit Cancel(id);
    }
    function PledgeAmount(uint id, uint _amount) external idExist(id) pledgingAmount(_amount){
        Campaign storage campaign = campaigns[id];
        // adding the amount pledge to the total Amountpledge
        require(block.timestamp < campaign.finishedtime, "Ended already");
        require(block.timestamp > campaign.Starttime, "Campaign not started");
        campaign.Amountpledge += _amount;
        // updating the balance of users
        AmountpledgedbyUser[id][msg.sender] += _amount;
        // transfer the tokens from users to this contract address
        Token.transferFrom(msg.sender, address(this), _amount);
         emit Pledge(msg.sender,  _amount);

    }
    function UnPledgeAmount(uint id , uint _amount) external idExist(id) pledgingAmount(_amount){
        Campaign storage campaign = campaigns[id];
        require(block.timestamp < campaign.finishedtime, "Ended already");
        require(block.timestamp > campaign.Starttime, "Campaign not started");
        // subtracting amount from total Amountpledge
        campaign.Amountpledge -= _amount;
        // updating the balance of users
        AmountpledgedbyUser[id][msg.sender] -= _amount;
        // transfer the tokens to users
        Token.transfer(msg.sender, _amount);
        emit unpledged(msg.sender,  id,  _amount);
    }
    function RefundPledgeAmount(uint id) external idExist(id) {
        Campaign storage campaign = campaigns[id];
        require(block.timestamp >= campaign.finishedtime, "Not ended yet");
        require(campaign.Amountpledge < campaign.goal, "pledgeAmount less than goal");
        require(!campaign.claimed, "Claimed already");  
        // getting the balance of users
        uint balance = AmountpledgedbyUser[id][msg.sender];
        // resetting to zero to avoid re-entrancy
        AmountpledgedbyUser[id][msg.sender] = 0;
        if (balance <= 0){
            revert NothingPledged();
        }
        // transfer tokens back to users
        Token.transfer(msg.sender, balance);
        emit Refund(msg.sender, balance);
    }
    function ClaimedGoal(uint id) external idExist(id) {
        Campaign storage campaign = campaigns[id];
        require(campaign.CreatorOfCampaign == msg.sender, "Not owner");
        require(block.timestamp >= campaign.finishedtime, "Not ended yet");
        require(campaign.Amountpledge >= campaign.goal, "pledgeAmount less than goal");
        require(!campaign.claimed, "Claimed already");
        // The creator get the tokens 
        Token.transfer(campaign.CreatorOfCampaign, campaign.Amountpledge);
        campaign.claimed = true;
        emit Claim(msg.sender, id, campaign.Amountpledge);
    }
}