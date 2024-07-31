// SPDX-License-Identifier: MIT 
pragma solidity 0.8.19;

interface IERC721{ 
     function transferFrom(address from, address to, uint256 tokenId) external;
}

contract EnglishAuction {
    address public seller;
    uint nftid;
    IERC721 public NFT;
    uint public AuctionPrice;
    address public highestBidder;
    uint duration;
    mapping(address => uint) public bids;
    uint public highestBid;
    uint public EndAt;
    bool public Started;
    bool public Ended;
    // events
    event Bid(address indexed bidders, uint indexed bidprice);
    event withdraws(address owners, uint price);
    event ends(address highestBidder, uint price);

    constructor(
        uint _nftid,
        address _nft,
        uint _duration,
        uint _startingBidPrice
    ) {
        seller = msg.sender;
        nftid = _nftid;
        NFT = IERC721(_nft);
        duration = _duration;
        AuctionPrice = _startingBidPrice;
    }
    // only seller can call
    // it starts the auction
    function start() external  {
        require(seller == msg.sender, "only seller is authorised");
        require(!Started, "auction started already");
        Started = true;
        EndAt = uint32(block.timestamp + duration);
        NFT.transferFrom(seller, address(this), nftid);
    }
    // function where bidders can actually bid on the nft token
    function bid() external payable{
        require(Started, "auction not started yet");
        require(block.timestamp < EndAt, "Ended already");
        require(msg.value > highestBid, "value is less than highest bid");
        if (highestBidder != address(0)){
            bids[highestBidder] += highestBid;
        }
        highestBidder = msg.sender;
        highestBid = msg.value;
        emit Bid(msg.sender, msg.value);
    }
    // bidders that dont have the highest bid can withdraw
    function withdraw() external payable {
        uint bal = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);
        emit withdraws(msg.sender, bal);
    }
     // time left for the auction
	function timeLeft() public view returns (uint256) {
         return auctionTimeEnded - block.timestamp;
     }

    // can only be called by the highest bidder 
    // eth is transfered to the seller
    // highest bidder get the nft in return
    function end() external payable {
        require(msg.sender == highestBidder, "You are not the highest bidder");
        require(block.timestamp > EndAt, "The auction hasnt ended yet");
        Ended = true;

        if (highestBidder != address(this)){
            NFT.transferFrom(address(this), highestBidder, nftid);
            payable(seller).transfer(highestBid);
        } else {
            NFT.transferFrom(address(this), seller, nftid);
        }
        emit ends(highestBidder, highestBid);
    }
}
