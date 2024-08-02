// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Func {
    function func1() external view returns(uint, uint){
        return(1, block.timestamp);
    }
    function func2() external view returns(uint, uint){
        return(1, block.timestamp);
    }
    // function to get the bytes of this function
    function getFunc1() external pure returns(bytes memory){
        return abi.encodeWithSelector(this.func1.selector);
    }
    // function to get the bytes of this function
    function getFunc2() external pure returns(bytes memory) {
        return abi.encodeWithSelector(this.func2.selector);
    }
}
contract MultiCall {
    // function to multicall functions by using bytes data and address of the contract to call
    function multicall(address[] calldata targets, bytes[] calldata data) external view returns(bytes[] memory) {
        require(targets.length == data.length, "invalid length");
        bytes[] memory results = new bytes[](data.length);
        for(uint i; i < targets.length; i++){
            (bool success, bytes memory result) = targets[i].staticcall(data[i]);
            require(success, "failed");
            results[i] = result;
        }
        return results;
    }
}
