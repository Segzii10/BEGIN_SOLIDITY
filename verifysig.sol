// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

contract Verify {
    function VerifySig(address signer, string memory message, bytes memory sig)
    external pure returns(bool) {
        bytes32 getMessageHash = getMessagehash(message);
        bytes32 EthsigMessageHash = ethsignMessage(getMessageHash);
        return recover(EthsigMessageHash, sig) == signer;
    }
    function getMessagehash(string memory _message) public pure returns(bytes32){
        return keccak256(abi.encodePacked(_message));
    }
    // done offchain where the user needs to sign the message
    function ethsignMessage(bytes32 MessageHash) public pure returns(bytes32){
        return keccak256(abi.encodePacked(MessageHash));
    }
    function recover(bytes32 EthsigMesageHash, bytes memory sig) public pure returns (address){
        (bytes32 r, bytes32 s, uint8 v) = split(sig);
        return ecrecover(EthsigMesageHash, v, r, s);
    }
    function split(bytes memory sig) internal pure returns (bytes32 r, bytes32 s, uint8 v) {
    require(sig.length == 65, "Invalid signature length");
    assembly {
        r := mload(add(sig, 32))
        s := mload(add(sig, 64))
        v := byte(0, mload(add(sig, 96)))
    }
    }
}