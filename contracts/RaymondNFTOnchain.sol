// SPDX-License-Identifier: MIT
pragma solidity  ^0.8.28;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";



contract RaymondNFT is ERC721, ERC721URIStorage{
using Strings for uint256;
uint tokenId_;

    constructor(string memory _name, string memory _symbol )
        ERC721(_name, _symbol){
            ++tokenId_;
            _safeMint(msg.sender, tokenId_);
            _setTokenURI(tokenId_, generateTokenURI(tokenId_));
        }

    function mintRaymondNFT(address to) external {
    ++tokenId_;
    _safeMint(to, tokenId_);
    _setTokenURI(tokenId_, generateTokenURI(tokenId_));
    }

    function createCharacter(uint) public view returns(string memory){
        bytes memory svg = abi.encodePacked(
           '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 350 350">',
        '<defs>',
            '<linearGradient id="bg" x1="0%" y1="0%" x2="100%" y2="100%">',
                '<stop offset="0%" stop-color="#0f2027"/>',
                '<stop offset="50%" stop-color="#203a43"/>',
                '<stop offset="100%" stop-color="#2c5364"/>',
            '</linearGradient>',
            '<radialGradient id="glow" cx="50%" cy="50%" r="50%">',
                '<stop offset="0%" stop-color="#00f2ff" stop-opacity="0.8"/>',
                '<stop offset="100%" stop-color="#00f2ff" stop-opacity="0"/>',
            '</radialGradient>',
        '</defs>',

        '<rect width="100%" height="100%" fill="url(#bg)"/>',

        '<circle cx="175" cy="175" r="110" fill="url(#glow)"/>',

        '<circle cx="175" cy="175" r="90" fill="#0d1117" stroke="#00f2ff" stroke-width="4"/>',

        '<text x="50%" y="45%" text-anchor="middle" fill="#00f2ff" ',
        'font-family="monospace" font-size="22" dominant-baseline="middle">',
        'ON-CHAIN NFT',
        '</text>',

        '<text x="50%" y="55%" text-anchor="middle" fill="white" ',
        'font-family="monospace" font-size="16" dominant-baseline="middle">',
        'Token #', Strings.toString(tokenId_),
        '</text>',

        '</svg>'
        );
       return string(
        abi.encodePacked(
            "data:image/svg+xml;base64,", 
            Base64.encode(svg)
        )
    );
    }

    function generateTokenURI(uint256 tokenId) public view returns (string memory){
    bytes memory dataURI = abi.encodePacked(
        '{',
            '"name": "Raymond NFT #', tokenId.toString(), '",',
            '"description": "This is my NFT living onchain",',
            '"image": "', createCharacter(tokenId), '"',
        '}'
    );
    return string(
        abi.encodePacked(
            "data:application/json;base64,", 
            Base64.encode(dataURI)
        )
    );
    }

   function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
    return super.tokenURI(tokenId);
    }


    //  function tokenURI(uint256) public pure virtual override returns (string memory) {
    //     return "ipfs://bafkreievv2c7k2kq3bm5ijmskbvccvuwjn4k4b5ik2wbww5mvz64ybaksu";
    //  }

}

