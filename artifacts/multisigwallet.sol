// SPDX-License-Identifier: MIT 
pragma solidity 0.8.19;

/*
Only required owners can execute a transaction
such transaction has to reach a certain numbers
of owners before executed
Only owners can approve such transactions and revoke the
transactions as well
*/

contract MultiSigWallet {
    // Events
    // Emitted when a deposit is made to the wallet
    event Deposit(address indexed sender, uint256 value);
    // Emitted when a transaction is submitted
    event SubmitTransaction(
        address indexed owner,
        uint256 indexed txIndex,
        address indexed to,
        uint256 value,
        bytes data
    );

    // Emitted when a transaction is confirmed
    event ConfirmTransaction(address indexed owner, uint256 indexed txIndex);

    // Emitted when a confirmation is revoked
    event RevokeConfirmation(address indexed owner, uint256 indexed txIndex);

    // Emitted when a transaction is executed
    event ExecuteTransaction(address indexed owner, uint256 indexed txIndex);

    // array of wallet owners
    address[] public owners;
    // check if an address is an owner
    mapping(address => bool) public isowner;
    // Number of required confirmations for a transaction to be executed
    uint public required;
    // Struct to store transaction details
    struct Transactions {
        address to;
        uint value;
        bytes data;
        bool executed;
    }
    // Mapping to check if a transaction is confirmed by a specific owner
    mapping(uint => mapping(address => bool)) public isconfirmed;

    // Array to store all transactions
    Transactions [] public transactions;
    // modifier to make sure it is only the owners can perform transactions
    modifier OnlyOwner() {
        require(isowner[msg.sender], "Not authorized");
        _;
    }
    // makes sure the transaction existed
    modifier TxExists(uint _txid) {
        require(_txid <= transactions.length, "Tx id doesnt exist");
        _;
    }
    // check if not been approved by any of the owner
    modifier notApproved(uint _txid) {
        require(!isconfirmed[_txid][msg.sender], "Transaction has been approved");
        _;
    }
    // check if transaction hasnot been executed yet
    modifier notexecuted(uint _txid) {
        require(transactions[_txid].executed == false, "transaction has been executed");
        _;
    }
     // Constructor that takes in array of wallet owners and required confirmed transactions
    constructor (address[] memory _owners, uint _required) payable {
        require(_owners.length > 0, "owners are required");
        require(_required > 0 && _required <= _owners.length, "invalid required of owners");
        for (uint i; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "invalid address owner");
            require(!isowner[owner], "owner is not unique");
            isowner[owner] = true;
            owners.push(owner);
            required = _required;
        }
    }
    // function to receive ether
    receive() external payable {
        require(msg.value > 0, "Not up to minimum ether");
        emit Deposit(msg.sender, msg.value);
    }
    // function to submit any transaction through the owners of the contract
    function submitTransaction(address _to, uint _value, bytes calldata _data) 
    external OnlyOwner {
        transactions.push(Transactions(_to, _value, _data, false));
        emit SubmitTransaction(msg.sender, owners.length-1, _to, _value, _data);
    }
    // function to approve any transactions by any owner of the contract
    function approve(uint txid) external OnlyOwner TxExists(txid) notApproved(txid) notexecuted(txid) {
        isconfirmed[txid][msg.sender] = true;
         emit ConfirmTransaction(msg.sender, txid);
    }
    // function to get the count of each transactions
    function _getApprovedCount(uint txid) private view returns(uint count){
        for (uint i; i < owners.length; i++) {
            if(isconfirmed[txid][owners[i]]){
                count++;
            }
        }
    }
    // function to execute the transactions
    function ExecuteTransactions(uint txid) external OnlyOwner notexecuted(txid) {
        require(_getApprovedCount(txid) >= required, "Not up to minimum to execute this transaction");
        Transactions storage transaction = transactions[txid];
        transaction.executed = true;
        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "transaction failed");
        emit ExecuteTransaction(msg.sender, txid);
    }
    // function to revoke the transaction that has been approved before executed
    function revoke(uint txid) external OnlyOwner TxExists(txid) notexecuted(txid){
        require(isconfirmed[txid][msg.sender], "Not approved by you");
        isconfirmed[txid][msg.sender] = false;
    }  
}
