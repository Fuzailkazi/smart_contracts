// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract EventManagement {
    struct Event {
        uint256 eventId;
        string name;
        string location;
        uint256 date;
        address organizer;
        uint256 totalTickets;
        uint256 availableTickets;
        uint256 ticketPrice;
    }

    Event[] public events;
    uint256 public totalEvents;

    mapping(uint256 => mapping(address => uint256)) public tickets;

    event EventCreated(uint256 indexed eventId, string name);
    event TicketsPurchased(uint256 indexed eventId, address indexed buyer, uint256 tickets);

    function createEvent(
        string memory _name,
        string memory _location,
        uint256 _date,
        uint256 _totalTickets,
        uint256 _ticketPrice
    ) public {
        events.push(
            Event(
                totalEvents,
                _name,
                _location,
                _date,
                msg.sender,
                _totalTickets,
                _totalTickets,
                _ticketPrice
            )
        );
        totalEvents++;
        emit EventCreated(totalEvents - 1, _name);
    }

    function buyTickets(uint256 _eventId, uint256 _tickets) public payable {
        require(_eventId < totalEvents, "Event does not exist");
        Event storage selectedEvent = events[_eventId];
        require(_tickets <= selectedEvent.availableTickets, "Not enough tickets available");
        require(msg.value == selectedEvent.ticketPrice * _tickets, "Incorrect amount sent");

        tickets[_eventId][msg.sender] += _tickets;
        selectedEvent.availableTickets -= _tickets;
        emit TicketsPurchased(_eventId, msg.sender, _tickets);
    }

    function getEvent(uint256 _eventId)
        public
        view
        returns (
            string memory,
            string memory,
            uint256,
            address,
            uint256,
            uint256
        )
    {
        require(_eventId < totalEvents, "Event does not exist");
        Event storage selectedEvent = events[_eventId];
        return (
            selectedEvent.name,
            selectedEvent.location,
            selectedEvent.date,
            selectedEvent.organizer,
            selectedEvent.totalTickets,
            selectedEvent.availableTickets
        );
    }

    function getTicketCount(uint256 _eventId, address _buyer) public view returns (uint256) {
        return tickets[_eventId][_buyer];
    }
    
    function cancelEvent(uint256 _eventId) public {
        require(_eventId < totalEvents, "Event does not exist");
        Event storage selectedEvent = events[_eventId];
        require(msg.sender == selectedEvent.organizer, "Only the organizer can cancel the event");
        
        uint256 totalRefund = selectedEvent.availableTickets * selectedEvent.ticketPrice;
        payable(msg.sender).transfer(totalRefund);
        selectedEvent.availableTickets = 0;
    }
    
    function withdrawFunds() public {
        uint256 totalBalance = address(this).balance;
        payable(msg.sender).transfer(totalBalance);
    }
}
