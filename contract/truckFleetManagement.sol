//SPDX-License-Identifier: UNLICENSED 
pragma solidity ^0.8.0;

contract TruckFleetTimeManagement {
    
    struct Truck {
        string truckName;
        address truckOwner;
        bool available;
        uint256 rentalPrice;
        uint256 availableStartTime;
        uint256 availableEndTime;
    }
    
    mapping(uint256 => Truck) public trucks;
    uint256 public truckId;
    
    

    function registerTruck(string memory _truckName,
     uint256 _rentalPrice, 
     uint256 _availableStartTime, 
     uint256 _availableEndTime) public {
        require(_availableStartTime < _availableEndTime, "Invalid time range.");
        require(_rentalPrice > 0 , "The price of the truck should be greater than 0");
            trucks[truckId] = Truck(_truckName,
            msg.sender,
            true,
             _rentalPrice * 10**18,
            _availableStartTime,
            _availableEndTime);
            truckId++;
    }
    
    function placeBid(uint256 _truckId,
        uint256 _startTime,
        uint256 _rentalPrice,
        uint256 _endTime) public payable {
        require(trucks[_truckId].available == true, "Truck is not available for rent.");
        require(msg.value >= trucks[_truckId].rentalPrice, "Bid amount is less than rental price.");
        require(_startTime >= trucks[_truckId].availableStartTime && _endTime <= trucks[_truckId].availableEndTime, "Invalid time range.");
        
        address payable truckOwner = payable(trucks[_truckId].truckOwner);
        truckOwner.transfer(msg.value);
        
        trucks[_truckId].available = false;
    }
    
    function getTruck(uint256 _truckId) public view returns (string memory, address, bool, uint256, uint256, uint256) {
        return (trucks[_truckId].truckName,
            trucks[_truckId].truckOwner,
            trucks[_truckId].available,
            trucks[_truckId].rentalPrice,
            trucks[_truckId].availableStartTime,
            trucks[_truckId].availableEndTime);
    }

    function destroy() public {
         //require(msg.sender == address(truckOwner), "Only the contract owner can destroy the contract.");
        selfdestruct(payable(msg.sender));
    }
    
}
