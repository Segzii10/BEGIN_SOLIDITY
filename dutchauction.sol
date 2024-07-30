// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
/*
This an auction of an nft token
it presented a simple dutch auction
where seller starting price decreases with time at a discount rate
*/
interface IERC721 {
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
}

contract Auction {
    address public seller;
    uint public startingPrice;
    uint public discountRate;
    uint public Starttime;
    uint public Endtime;
    uint public nftid;
    uint public Duration;
    bool public Ended;
    IERC721 public NFT;
    constructor (
        uint _startingPrice,
        uint _discountRate,
        uint _duration,
        uint _nftid,
        address nft
    ){
        seller = msg.sender;
        startingPrice = _startingPrice;
        require(startingPrice >= discountRate * _duration);
        discountRate = _discountRate;
        nftid = _nftid;
        Duration = _duration;
        NFT = IERC721(nft);
        Starttime = block.timestamp;
        Endtime = block.timestamp + _duration;
        Ended = false;
    }
    // get the price of the token
    function getPrice() public view returns(uint currentPrice) {
        uint timeElapsed = block.timestamp - Starttime;
        uint discount = discountRate * timeElapsed;
        currentPrice = startingPrice - discount;
    }
    // function that buys the token
    function buy() external payable {
        require(!Ended, "auction has ended");
        uint currentPrice = getPrice();
        require(msg.value >= currentPrice, "minimum price shoud be the current price");
        NFT.transferFrom(seller, msg.sender, nftid);
        uint refund = msg.value - currentPrice;
        if(msg.value > currentPrice) {
            payable(msg.sender).transfer(refund);
        }
        payable(seller).transfer(msg.value);
        Ended = true;
    }
}
