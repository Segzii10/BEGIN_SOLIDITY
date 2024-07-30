// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

interface IERC20 {
    // Returns the amount of tokens in existence.
   

    // Returns the amount of tokens owned by `account`.
    function balanceOf(address account) external view returns (uint256);

    // Moves `amount` tokens from the caller's account to `recipient`.
    function transfer(address recipient, uint256 amount) external returns (bool);

    // Returns the remaining number of tokens that `spender` will be allowed to spend on behalf of `owner` through `transferFrom`.
    function allowance(address owner, address spender) external view returns (uint256);

    // Sets `amount` as the allowance of `spender` over the caller's tokens.
    function approve(address spender, uint256 amount) external returns (bool);

    // Moves `amount` tokens from `sender` to `recipient` using the allowance mechanism.
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    // Emitted when `value` tokens are moved from one account (`from`) to another (`to`).
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Emitted when the allowance of a `spender` for an `owner` is set by a call to `approve`.
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract ERC20 is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public _totalSupply;
    mapping(address => uint256) public balances;
    mapping(address => mapping(address => uint256)) public allowances;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
        decimals = 18; // Standard ERC-20 decimals
    }
    function balanceOf(address account) external view returns (uint256){
        return balances[account];
    }

    function totalSupply() external view  returns (uint256){
        return _totalSupply;
    }
    function transfer(address recipient, uint256 amount) external returns (bool){
        balances[msg.sender] -= amount;
        balances[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }
    function approve(address spender, uint256 amount) external override returns (bool){
        allowances[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
    function allowance(address owner, address spender) external view returns (uint256){
        return allowances[owner][spender];
    }
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){
        allowances[sender][recipient] = amount;
        balances[sender] -= amount;
        balances[msg.sender] += amount;
        emit Transfer(sender, msg.sender, amount);
        return true;
    }









}
