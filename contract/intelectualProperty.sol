// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IntellectualProperty {
    struct Work {
        string title;
        address owner;
        uint256 royaltyPercentage;
    }

    mapping(uint256 => Work) public works;
    uint256 public workCount;

    event WorkRegistered(uint256 indexed workId, string title, address indexed owner, uint256 royaltyPercentage);

    constructor() {
        workCount = 0;
    }

    function registerWork(string memory title, uint256 royaltyPercentage) public {
        require(bytes(title).length > 0, "Title must be provided");
        require(royaltyPercentage > 0 && royaltyPercentage <= 100, "Invalid royalty percentage");

        workCount++;

        works[workCount] = Work({
            title: title,
            owner: msg.sender,
            royaltyPercentage: royaltyPercentage
        });

        emit WorkRegistered(workCount, title, msg.sender, royaltyPercentage);
    }

    function getWork(uint256 workId) public view returns (string memory, address, uint256) {
        require(workId > 0 && workId <= workCount, "Invalid work ID");

        Work storage work = works[workId];
        return (work.title, work.owner, work.royaltyPercentage);
    }
}
