// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAO {
    struct Proposal {
        uint256 id;
        address creator;
        string description;
        uint256 yesVotes;
        uint256 noVotes;
        bool executed;
    }

    mapping(uint256 => Proposal) public proposals;
    uint256 public proposalCount;

    mapping(address => bool) public members;

    constructor() {
        members[msg.sender] = true;
    }

    function addProposal(string memory description) public {
        require(members[msg.sender], "Only members can add proposals");

        proposalCount++;
        proposals[proposalCount] = Proposal({
            id: proposalCount,
            creator: msg.sender,
            description: description,
            yesVotes: 0,
            noVotes: 0,
            executed: false
        });
    }

    function vote(uint256 proposalId, bool support) public {
        require(members[msg.sender], "Only members can vote");
        require(proposalId > 0 && proposalId <= proposalCount, "Invalid proposal ID");
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal has already been executed");

        if (support) {
            proposal.yesVotes++;
        } else {
            proposal.noVotes++;
        }
    }

    function executeProposal(uint256 proposalId) public {
        require(proposalId > 0 && proposalId <= proposalCount, "Invalid proposal ID");
        Proposal storage proposal = proposals[proposalId];
        require(!proposal.executed, "Proposal has already been executed");
        require(proposal.yesVotes > proposal.noVotes, "Proposal does not have enough support");

        proposal.executed = true;

        // Perform the execution of the proposal here
        // This could involve transferring funds, updating state, or invoking external contracts
        // Implement your specific logic based on the requirements of the proposal
    }

    function addMember(address member) public {
        require(members[msg.sender], "Only members can add members");
        members[member] = true;
    }

    function removeMember(address member) public {
        require(members[msg.sender], "Only members can remove members");
        require(member != msg.sender, "Cannot remove yourself");
        delete members[member];
    }

    function isMember(address account) public view returns (bool) {
        return members[account];
    }
}
