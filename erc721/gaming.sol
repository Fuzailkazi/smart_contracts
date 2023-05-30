// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GamingItems is ERC721 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct GameItem {
        string name;
        uint256 power;
        uint256 level;
        bool isStaked;
        address owner;
        uint256 price;
    }

    mapping(uint256 => GameItem) private _gameItems;

    constructor() ERC721("GamingItems", "GMI") {}

    function createGameItem(string memory name, uint256 power, uint256 level, string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, tokenURI);

        GameItem memory newGameItem = GameItem(name, power, level, false, msg.sender, 0);
        _gameItems[newTokenId] = newGameItem;

        return newTokenId;
    }

    function getGameItem(uint256 tokenId) public view returns (string memory, uint256, uint256, bool, address, uint256) {
        require(_exists(tokenId), "GamingItems: Token does not exist");

        GameItem storage gameItem = _gameItems[tokenId];
        return (gameItem.name, gameItem.power, gameItem.level, gameItem.isStaked, gameItem.owner, gameItem.price);
    }

    function buyGameItem(uint256 tokenId) public payable {
        require(_exists(tokenId), "GamingItems: Token does not exist");

        GameItem storage gameItem = _gameItems[tokenId];
        require(!gameItem.isStaked, "GamingItems: Token is currently staked");
        require(msg.value >= gameItem.price, "GamingItems: Insufficient payment");

        address previousOwner = ownerOf(tokenId);

        _transfer(previousOwner, msg.sender, tokenId);
        gameItem.owner = msg.sender;

        payable(previousOwner).transfer(msg.value);
    }

    function sellGameItem(uint256 tokenId, uint256 price) public {
        require(_exists(tokenId), "GamingItems: Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "GamingItems: Not the owner of the item");

        GameItem storage gameItem = _gameItems[tokenId];
        gameItem.price = price;
    }

    function stakeGameItem(uint256 tokenId) public {
        require(_exists(tokenId), "GamingItems: Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "GamingItems: Not the owner of the item");

        GameItem storage gameItem = _gameItems[tokenId];
        require(!gameItem.isStaked, "GamingItems: Token is already staked");

        gameItem.isStaked = true;
    }

    function unstakeGameItem(uint256 tokenId) public {
        require(_exists(tokenId), "GamingItems: Token does not exist");
        require(ownerOf(tokenId) == msg.sender, "GamingItems: Not the owner of the item");

        GameItem storage gameItem = _gameItems[tokenId];
        require(gameItem.isStaked, "GamingItems: Token is not staked");

        gameItem.isStaked = false;
    }
}
