//  SPDX-License-Identifier: UNLICESED
pragma solidity ^0.8.10;

contract DWGotTalent {

    address[] public judgesList;
    address[] public finalistsList;

    mapping(address => bool) public isJudge;
    mapping(address => bool) public isFinalist;

    uint public judgeWeightage;
    uint public audienceWeightage;

    address public owner;

    enum Stage {
        REG,
        VOTE,
        END
    }
    Stage public votingStage;

    mapping(address => address) public votedForAccount;
    mapping(address => uint256) public voteCount;
    uint256 public maxVotes;

    constructor() {
        owner = msg.sender;
        votingStage = Stage.REG;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "NOT_OWNER");
        _;
    }

    //this function defines the addresses of accounts of judges
    function selectJudges(address[] memory arrayOfAddresses) external onlyOwner {
        require(votingStage == Stage.REG, "INVALID_STAGE");
        for(uint i = 0; i < judgesList.length; i++) {
            delete isJudge[judgesList[i]];
        }
        for(uint i = 0; i < arrayOfAddresses.length; i++) {
            require(arrayOfAddresses[i] != address(0), "ZERO_ADD");
            require(arrayOfAddresses[i] != owner, "OWNER_NA");
            require(!isFinalist[arrayOfAddresses[i]], "NA");
            isJudge[arrayOfAddresses[i]] = true;
        }
        judgesList = arrayOfAddresses;
    }

    bool public weightageAssigned;

    //this function adds the weightage for judges and audiences
    function inputWeightage(
        uint _judgeWeightage, 
        uint _audienceWeightage
    ) external onlyOwner {
        require(votingStage == Stage.REG, "INVALID_STAGE");
        judgeWeightage = _judgeWeightage;
        audienceWeightage = _audienceWeightage;
        weightageAssigned = true;
    }

    //this function defines the addresses of finalists
    function selectFinalists(address[] memory arrayOfAddresses) external onlyOwner {
        require(votingStage == Stage.REG, "INVALID_STAGE");
        for(uint i = 0; i < finalistsList.length; i++) {
            delete isFinalist[finalistsList[i]];
        }
        for(uint i = 0; i < arrayOfAddresses.length; i++) {
            require(arrayOfAddresses[i] != address(0), "ZERO_ADD");
            require(arrayOfAddresses[i] != owner, "OWNER_NA");
            require(!isJudge[arrayOfAddresses[i]], "NA");
            isFinalist[arrayOfAddresses[i]] = true;
        }
        finalistsList = arrayOfAddresses;
    }

    //this function strats the voting process
    function startVoting() external onlyOwner {
        require(votingStage == Stage.REG, "INVALID_STAGE");
        require(judgesList.length > 0, "NO_JUDGES");
        require(finalistsList.length > 0, "NO_FINALISTS");
        // require(judgeWeightage > 0 && audienceWeightage > 0, "NO_WEIGHTAGE");
        require(weightageAssigned, "WEIGHTAGE_NA");
        votingStage = Stage.VOTE;
    }

    //this function is used to cast the vote 
    function castVote(address finalistAddress) public {
        require(votingStage == Stage.VOTE, "INVALID_STAGE");
        require(isFinalist[finalistAddress], "NOT_FINALIST");
        address votedFor = votedForAccount[msg.sender];
        if(votedFor != address(0)) {
            if(isJudge[msg.sender])
                voteCount[finalistAddress] -= judgeWeightage;
            else
                voteCount[finalistAddress] -= audienceWeightage;
        }

        if(isJudge[msg.sender])
            voteCount[finalistAddress] += judgeWeightage;
        else
            voteCount[finalistAddress] += audienceWeightage;
        
        if(voteCount[finalistAddress] > maxVotes)
            maxVotes = voteCount[finalistAddress];
    }

    //this function ends the process of voting
    function endVoting() external onlyOwner {
        require(votingStage == Stage.VOTE, "INVALID_STAGE");
        votingStage = Stage.END;
    }

    //this function returns the winner/winners
    function showResult() public view returns (address[] memory) {
        require(votingStage == Stage.END, "INVALID_STAGE");
        address[] memory winnerList = new address[](finalistsList.length);
        uint256 len;
        for(uint i = 0; i < finalistsList.length; i++) {
            if(voteCount[finalistsList[i]] == maxVotes)
                winnerList[len++] = finalistsList[i];
        }

        address[] memory list2 =  new address[](len);
        for(uint index = 0; index < len; index++) {
            if(winnerList[index] == address(0))
                break;
            list2[index] = winnerList[index];
        }
        return list2;
    }

}