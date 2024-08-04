// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract SimpleStorage {
    struct Person {
        string name;
        uint favoriteNumber;
    }
    Person [] public person;

    function takesin(string calldata _name,uint _favoriteNumber) external {
        person.push(Person(_name, _favoriteNumber));
    }
    function retrieve(uint id) external returns(string memory name, uint number){
        require(id < person.length, "invalid id");
        Person memory persons = person[id];
        name = persons.name;
        number = persons.favoriteNumber;
    } 
}