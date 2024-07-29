// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

/*
This contract will receive ether from anybody
Destroy the contract by forcing send ether to the deployer
The deployer will be another contract
*/

contract piggybank{
    address public owner;
    constructor()payable{}
    receive() external payable{} // no bytesdata
    fallback() external payable{} // there is bytesdata

    function withdraw() external {
        selfdestruct(payable(msg.sender));
    }
}
contract Ownerbank {
    /*
    get the balance of the contract
    call the contract and destroy as the deployer
    This send all ether to the deployer's address
    */

    function withdraw(piggybank _piggy) external {
        _piggy.withdraw();
    }
    
    function getBalance() external view returns(uint){
        return address(this).balance;

    }
}