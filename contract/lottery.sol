// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address public manager;
    address payable[] public players;

    constructor() {
        manager = msg.sender;
    }

    function enter() public payable {
        require(msg.value > 0, "Entry fee must be greater than 0");
        players.push(payable(msg.sender));
    }

    function pickWinner() public restricted {
        require(players.length > 0, "No players in the lottery");

        uint256 index = random() % players.length;
        address payable winner = players[index];
        winner.transfer(address(this).balance);

        players = new address payable[](0);
    }

    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.basefee, players.length)));
    }

    modifier restricted() {
        require(msg.sender == manager, "Only the manager can call this function");
        _;
    }

    function getPlayers() public view returns (address payable[] memory) {
        return players;
    }
}
