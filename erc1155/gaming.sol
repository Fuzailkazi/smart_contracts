// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract GamingItems is ERC1155 {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct GameItem {
        string name;
        uint256 power;
        uint256 level;
        uint256 price;
        address owner;
    }

    mapping(uint256 => GameItem) private _gameItems;
    mapping(address => mapping(uint256 => uint256)) private _balances;

    constructor(string memory uri) ERC1155(uri) {}

    function createGameItem(string memory name, uint256 power, uint256 level, uint256 price, string memory tokenURI) public returns (uint256) {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();

        _setURI(tokenURI);

        GameItem memory newGameItem = GameItem(name, power, level, price, msg.sender);
        _gameItems[newTokenId] = newGameItem;

        _mint(msg.sender, newTokenId, 1, "");

        return newTokenId;
    }

    function getGameItem(uint256 tokenId) public view returns (string memory, uint256, uint256, uint256, address) {
        require(_gameItems[tokenId].power > 0, "GamingItems: Token does not exist");

        GameItem storage gameItem = _gameItems[tokenId];
        return (gameItem.name, gameItem.power, gameItem.level, gameItem.price, gameItem.owner);
    }

    function buyGameItem(uint256 tokenId) public payable {
        require(_gameItems[tokenId].power > 0, "GamingItems: Token does not exist");

        GameItem storage gameItem = _gameItems[tokenId];
        require(msg.value >= gameItem.price, "GamingItems: Insufficient payment");

        _safeTransferFrom(address(this), msg.sender, tokenId, 1, "");

        address payable itemOwner = payable(gameItem.owner);
        itemOwner.transfer(msg.value);

        gameItem.owner = msg.sender;
        _balances[msg.sender][tokenId]++;
    }

    function sellGameItem(uint256 tokenId, uint256 price) public {
        require(_gameItems[tokenId].power > 0, "GamingItems: Token does not exist");
        require(_balances[msg.sender][tokenId] > 0, "GamingItems: Not the owner of the item");

        GameItem storage gameItem = _gameItems[tokenId];
        gameItem.price = price;
    }
}
