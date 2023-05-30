// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract IdentityVerification {
    struct Identity {
        string fullName;
        uint256 age;
        address verifier;
        bool verified;
    }

    mapping(address => Identity) public identities;

    event IdentityCreated(address indexed account, string fullName, uint256 age);
    event IdentityVerified(address indexed account, address indexed verifier);

    function createIdentity(string memory fullName, uint256 age) public {
        require(bytes(fullName).length > 0, "Full name must be provided");
        require(age >= 18, "Minimum age requirement not met");

        Identity storage identity = identities[msg.sender];
        require(bytes(identity.fullName).length == 0, "Identity already exists");

        identity.fullName = fullName;
        identity.age = age;

        emit IdentityCreated(msg.sender, fullName, age);
    }

    function verifyIdentity(address account) public {
        Identity storage identity = identities[account];
        require(bytes(identity.fullName).length > 0, "Identity does not exist");
        require(!identity.verified, "Identity is already verified");

        identity.verifier = msg.sender;
        identity.verified = true;

        emit IdentityVerified(account, msg.sender);
    }

    function getIdentity(address account) public view returns (string memory, uint256, address, bool) {
        Identity storage identity = identities[account];
        return (identity.fullName, identity.age, identity.verifier, identity.verified);
    }
}
