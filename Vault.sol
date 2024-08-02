// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./IERC20.sol";

contract Vault {
    uint public totalSupply;
    IERC20 public immutable token;

    mapping(address => uint) public balanceOf;

    constructor(address _token) {
        token = IERC20(_token);
    }

    /* 
    function to mint tokens
    updating the state variable totalsupply
    and the balance of the address given
    */    
    function _mint(address _to, uint _amount) private 
    {  
       totalSupply += _amount;
       balanceOf[_to] += _amount;
    }
    /*
    function to burn token from the total supply
    also burn it from the balance of the address of the caller
    */
    function _burn(address from, uint _amount) private 
    {
        totalSupply -= _amount;
        balanceOf[from] -= _amount;
    }
    function deposit(uint _amount) external {
        /*
        to get shares
        shares = aT/B
        where:
        a = amount deposited
        T = totalsupply
        B = balance of the depoitor
        */
        uint shares;
        uint _totalsupply = totalSupply;
        if(_totalsupply == 0){
            shares = _amount;
        }else{
            shares = (_amount * _totalsupply) / token.balanceOf(address(this));
        }
        _mint(msg.sender, _amount);
        token.transferFrom(msg.sender, address(this), _amount);
    }
    function withdraw(uint _shares) external
    {
        uint amount = (_shares * token.balanceOf(address(this))) / totalSupply;
        _burn(msg.sender, _shares);
        token.transfer(msg.sender, amount);
    }

}
