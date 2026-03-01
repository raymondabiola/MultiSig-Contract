// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract MyNFT is ERC721, ERC721URIStorage, AccessControl{
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint tokenId;

    constructor(string memory _name, string memory _symbol)ERC721(_name, _symbol){
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
    }

    function safeMint(address _to, string memory _tokenURI) external onlyRole(MINTER_ROLE){
        ++tokenId;
        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, _tokenURI);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return "ipfs://bafkreievv2c7k2kq3bm5ijmskbvccvuwjn4k4b5ik2wbww5mvz64ybaksu";
    }
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721URIStorage, AccessControl) returns (bool) {
       return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 _tokenId) public view virtual override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(_tokenId);
    }
}