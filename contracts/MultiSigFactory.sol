// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "./MultiSig.sol";

contract MultiSigFactory{

address[] public children;

 function createChild(address owner, uint8 quorum, uint8 totalSignatories) external{
    MultiSig multiSig = new MultiSig(owner, quorum, totalSignatories);
    children.push(address(multiSig));
 }

 function getChildAddress(uint _index) external view returns(address) {
    return children[_index];
 }
 
}
