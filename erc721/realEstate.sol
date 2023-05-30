// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract RealEstateToken is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct RealEstate {
        string propertyAddress;
        uint256 price;
        uint256 area;
        bool isForSale;
    }

    mapping(uint256 => RealEstate) private _realEstates;
    mapping(uint256 => address) private _propertyOwners;

    constructor() ERC721("RealEstateToken", "RET") {}

    function createRealEstate(string memory propertyAddress, uint256 price, uint256 area, string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        RealEstate memory newRealEstate = RealEstate(propertyAddress, price, area, false);
        _realEstates[newTokenId] = newRealEstate;
        _propertyOwners[newTokenId] = msg.sender;

        return newTokenId;
    }

    function getRealEstate(uint256 tokenId) public view returns (string memory, uint256, uint256, bool) {
        require(_exists(tokenId), "RealEstateToken: Token does not exist");

        RealEstate storage realEstate = _realEstates[tokenId];
        return (realEstate.propertyAddress, realEstate.price, realEstate.area, realEstate.isForSale);
    }

    function buyRealEstate(uint256 tokenId) public payable {
        require(_exists(tokenId), "RealEstateToken: Token does not exist");

        RealEstate storage realEstate = _realEstates[tokenId];
        require(realEstate.isForSale, "RealEstateToken: Property is not for sale");
        require(msg.value >= realEstate.price, "RealEstateToken: Insufficient payment");

        address previousOwner = ownerOf(tokenId);

        _transfer(previousOwner, msg.sender, tokenId);
        realEstate.isForSale = false;
        _propertyOwners[tokenId] = msg.sender;

        payable(previousOwner).transfer(msg.value);
    }

    function sellRealEstate(uint256 tokenId, uint256 price) public {
        require(_exists(tokenId), "RealEstateToken: Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "RealEstateToken: Not the owner of the property");

        RealEstate storage realEstate = _realEstates[tokenId];
        realEstate.isForSale = true;
        realEstate.price = price;
    }
}
