// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RealEstateContract {
    struct Property {
        address payable seller;
        address buyer;
        uint256 price;
        bool isSold;
    }

    mapping(uint256 => Property) public properties;
    uint256 public propertyCount;

    event PropertyAdded(uint256 indexed propertyId, address indexed seller, uint256 price);
    event PropertySold(uint256 indexed propertyId, address indexed seller, address indexed buyer, uint256 price);

    function addProperty(uint256 price) public {
        require(price > 0, "Price must be greater than 0");

        propertyCount++;
        properties[propertyCount] = Property({
            seller: payable(msg.sender),
            buyer: address(0),
            price: price,
            isSold: false
        });

        emit PropertyAdded(propertyCount, msg.sender, price);
    }

    function buyProperty(uint256 propertyId) public payable {
        require(propertyId > 0 && propertyId <= propertyCount, "Invalid property ID");
        Property storage property = properties[propertyId];
        require(!property.isSold, "Property is already sold");
        require(msg.value >= property.price, "Insufficient funds");

        property.buyer = msg.sender;
        property.isSold = true;

        property.seller.transfer(msg.value);

        emit PropertySold(propertyId, property.seller, property.buyer, property.price);
    }

    function getProperty(uint256 propertyId) public view returns (address, address, uint256, bool) {
        require(propertyId > 0 && propertyId <= propertyCount, "Invalid property ID");
        Property storage property = properties[propertyId];
        return (property.seller, property.buyer, property.price, property.isSold);
    }
}
