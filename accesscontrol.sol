// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

// ADMIN can only grant role to any address
// ADMIN is the deployer of the contract
// bytes32 => role => bool

contract AccessControl {
    mapping(bytes32 => mapping(address => bool)) public roles;
    event GrantRole(bytes32 indexed data, address indexed account);

    // 0xdf8b4c520ffe197c5343c6f5aec59570151ef9a492f2c624fd45ddde6135ec42
    bytes32 private constant ADMINROLE = keccak256(abi.encodePacked("ADMIN"));
    //  0x59daf22c92a94d3cc0dd1160ba0b142bdd9a54f280fcfa7508a89db52d34fac0
    bytes32 private constant USERROLE = keccak256(abi.encodePacked("User"));
    

    constructor() {
        _grantRole(ADMINROLE, msg.sender);
    }

    modifier OnlyRole(bytes32 _role){
        require(roles[_role][msg.sender], "not authorised");
        _;
    }
   
    function _grantRole(bytes32 role, address user) internal {
        roles[role][user] = true;
        emit GrantRole(role, user);
    }
    
    function grantUserRole(bytes32 _role, address _user) external OnlyRole(ADMINROLE)  {
        _grantRole(_role, _user);
        emit GrantRole(_role, _user);
    }
   
    function revokeRole(bytes32 role, address user) external OnlyRole(ADMINROLE) {
        roles[role][user] = false;
        emit GrantRole(role, user);
    } 
}