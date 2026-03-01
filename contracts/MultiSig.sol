// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import "@openzeppelin/contracts/access/AccessControl.sol";

// check if has signed is true before a valid signer signs.

contract MultiSig is AccessControl {
    bytes32 public constant MULTI_SIG_CONTRACT_SIGNER_ROLE = keccak256("MULTI_SIG_CONTRACT_SIGNER_ROLE");
    uint8 public quorum;
    uint8 public constant minimumQuorum = 2;
    uint8 public totalSignatories;
    uint txIdCounter;
    
    address[] public signers;
    mapping(address => bool) isValidSigner;

    mapping(uint => mapping(address => bool)) hasSigned;


    struct Transaction{
        uint sigCount;
        address addr;
        uint amount;
        bool executed;
    }

    mapping(uint => Transaction) transaction;

    struct ChangeSignerIntent{
        address signer;
        address newSigner;
        uint creationTime;
        uint executionTime;
    }
    ChangeSignerIntent[] public changeSignerIntent;

    error EnterAtLeastTwoQuorum();
    error InvalidQuorumInputed(uint8 quorum, uint8 totalSignatories);
    error InvalidAddressInputAddressArray();
    error AddressAlreadySigner();
    error AddressCannotCreateMessage();
    error TransactionExecuted();
    error InvalidSigner();
    error InvalidTxId();
    error SignerAlreadySigned();
    error MaxSignersExceeded();
    error InvalidAmount();
    error ExecutionTimeNotYet();
    error TransferFailed();
    error InvalidAddress();
    error SignerAlreadyExist();
    error InvalidReplacementSigner();
    error InvalidCaller();
    error InvalidIndex();

    constructor(address owner, uint8 _quorum, uint8 _totalSignatories) {
        if(_quorum < minimumQuorum)revert EnterAtLeastTwoQuorum();
        if(_quorum > _totalSignatories) revert InvalidQuorumInputed(_quorum, _totalSignatories);
        signers.push(owner);
        _grantRole(DEFAULT_ADMIN_ROLE, owner);
        _grantRole(MULTI_SIG_CONTRACT_SIGNER_ROLE, owner);
        isValidSigner[msg.sender] = true;
        quorum = _quorum;
        totalSignatories = _totalSignatories;
    }

    function addSigners(address[] calldata _address) external onlyRole(DEFAULT_ADMIN_ROLE){
    for(uint i = 0; i < _address.length; i++){
    if(signers.length + _address.length > totalSignatories) revert MaxSignersExceeded();
    if(_address[i] == address(0)) revert InvalidAddressInputAddressArray();
    if(isValidSigner[_address[i]]) revert AddressAlreadySigner();
    signers.push(_address[i]);
    _grantRole(MULTI_SIG_CONTRACT_SIGNER_ROLE, _address[i]);
    isValidSigner[_address[i]] = true;
}
}

    function deposit() external payable{
    if(msg.value == 0) revert InvalidAmount();
    }

    function createTransaction(address _address, uint _amount) external{
    if(!isValidSigner[msg.sender]) revert AddressCannotCreateMessage();
    if(_address == address(0)) revert InvalidAddress();
    if(_amount == 0) revert InvalidAmount();
    ++txIdCounter;
    transaction[txIdCounter].addr = _address;
    transaction[txIdCounter].amount = _amount;
}

// [0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2, 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db, 0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB,  0x617F2E2fD72FD9D5503197092aC168c91465E7f2]
    function signTransaction(uint _txIdCounter)public{
    if(_txIdCounter == 0) revert InvalidTxId();
    if(transaction[_txIdCounter].addr == address(0)) revert InvalidTxId();
    if(transaction[_txIdCounter].executed) revert TransactionExecuted();
    if(hasSigned[_txIdCounter][msg.sender]) revert SignerAlreadySigned();
    if(!isValidSigner[msg.sender]){ 
        revert InvalidSigner();
    }else {
        transaction[_txIdCounter].sigCount += 1;
        hasSigned[_txIdCounter][msg.sender] = true;
    } 

    if(transaction[_txIdCounter].sigCount == quorum){
    (bool result,) = payable(transaction[_txIdCounter].addr).call{value: transaction[_txIdCounter].amount}("");
    if(!result) revert TransferFailed();
    transaction[_txIdCounter].executed = true;
    }
    }

function createIntentToChangeSigner(address _toBeReplacedSigner, address _replacementSigner) public onlyRole(MULTI_SIG_CONTRACT_SIGNER_ROLE) {
    if(_replacementSigner == address(0)) revert InvalidAddress();
    if(isValidSigner[_replacementSigner]) revert SignerAlreadyExist();
    if(!isValidSigner[_toBeReplacedSigner]) revert InvalidReplacementSigner();
    

    if(!isValidSigner[msg.sender]){ 
        revert InvalidCaller();
    }else {
            // 432_000 is 5 days;
        ChangeSignerIntent memory newIntent = ChangeSignerIntent(_toBeReplacedSigner, _replacementSigner, block.timestamp, block.timestamp + 432_000);
        changeSignerIntent.push(newIntent);
    }
}

function executeIntentToChangeSigner(uint _index)external onlyRole(MULTI_SIG_CONTRACT_SIGNER_ROLE){
        if(_index >= changeSignerIntent.length) revert InvalidIndex();
        if(changeSignerIntent[_index].executionTime > block.timestamp){
            revert ExecutionTimeNotYet();
        }else{
        isValidSigner[changeSignerIntent[_index].signer] = false;
        isValidSigner[changeSignerIntent[_index].newSigner] = true;
        for(uint i = 0; i < signers.length ; i++){
            if(signers[i] == changeSignerIntent[_index].signer){
            if(hasRole(DEFAULT_ADMIN_ROLE, signers[i])){
            _revokeRole(DEFAULT_ADMIN_ROLE, signers[i]);
            _grantRole(DEFAULT_ADMIN_ROLE, changeSignerIntent[_index].newSigner);
            signers[i] = changeSignerIntent[_index].newSigner;
            _grantRole(MULTI_SIG_CONTRACT_SIGNER_ROLE, changeSignerIntent[_index].newSigner);
            break;
            }
            signers[i] = changeSignerIntent[_index].newSigner;
            _revokeRole(MULTI_SIG_CONTRACT_SIGNER_ROLE, changeSignerIntent[_index].signer);
            _grantRole(MULTI_SIG_CONTRACT_SIGNER_ROLE, changeSignerIntent[_index].newSigner);

            }
        }
        }
}

function getSigners() external view returns(address[] memory){
   return signers;
}

function checkIfSignerIsValid(address _address) external view returns(bool){
   return isValidSigner[_address];
}
}