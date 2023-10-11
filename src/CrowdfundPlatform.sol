// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
// import {console2} from "forge-std/Test.sol";
contract CrowdfundPlat{

    struct CrowdFund {
        string title; 
        uint256 fundingGoal;
        address owner;
        uint256 durationTime;
        bool isActive;
        uint256 fundingBalance;
        address[] contributors;  
    }
    uint256 public id;

    mapping(uint => CrowdFund)  crowd;
    //mapping of campaignid to address of contributors to amount contributed
    mapping(uint => mapping(address => uint)) public contribute;
    mapping(uint => mapping(address => bool)) public hasContributed;

    error InsufficientInput();
    error NotActive();
    error ExceededFundingGoal();
    error NotInDuration();
    error NotOwner();
    error TimeNotReached();
    event ProposeCampaign(uint id, string _title, uint256 _fundingGoal, uint256 _durationTime);
    event ContributeEth(uint indexed _ID, uint _fundingBalance, address contributor, uint amount);
    event CampaignEnds(uint indexed _ID, bool isActive);

    
    function proposeCampaign(string memory _title, uint256 _fundingGoal, uint256 _durationTime) external returns(uint _id) {
        id++;
        _id = id;
       CrowdFund storage crow = crowd[_id];
      
       crow.title = _title;
       crow.fundingGoal = _fundingGoal;
       crow.owner = msg.sender;
       crow.durationTime = _durationTime + block.timestamp;
       crow.isActive = true;

       emit ProposeCampaign(_id, _title, _fundingGoal, _durationTime);
    }

    
    function contributeEth(uint _ID) external payable{
        if(msg.value <= 0)  revert InsufficientInput();
         CrowdFund storage crow = crowd[_ID];
        if(crow.isActive != true) revert NotActive();
 
        // require(crow.fundingBalance < crow.fundingGoal, "Funding Goal Achieved");
        if(crow.fundingBalance + msg.value > crow.fundingGoal) revert ExceededFundingGoal();
        // require(block.timestamp <= crow.durationTime, "Not in duration");
        if (block.timestamp > crow.durationTime) revert NotInDuration();
        contribute[_ID][msg.sender] += msg.value;
        crow.fundingBalance += msg.value;
        if (!hasContributed[_ID][msg.sender]) {
           crow.contributors.push(msg.sender); 
           hasContributed[_ID][msg.sender] = true;
        }
        

        emit ContributeEth(_ID, crow.fundingBalance, msg.sender, contribute[_ID][msg.sender]);
    }

    function campaignEnds(uint _ID) external {
         CrowdFund storage crow = crowd[_ID];
        //  require(crow.isActive = true, "Already ended");
         if(crow.isActive != true) revert NotActive();
        // require(msg.sender == crow.owner, "Only Campaign owner");
        if(msg.sender != crow.owner) revert NotOwner();
        // require(crow.durationTime <= block.timestamp, "Time Has not been reached");
        if(crow.durationTime > block.timestamp) revert TimeNotReached();
        if(crow.fundingBalance < crow.fundingGoal) {
            // to refund everyone because we didn't reach the funding goal
            refundContributors(_ID);
        } else {
            markSuccessful(_ID);
        }
        emit CampaignEnds(_ID, false);
    }


    function refundContributors(uint _ID) internal {
         CrowdFund storage crow = crowd[_ID];
        address[] memory contributors = crow.contributors;
        for(uint i= 0; i < contributors.length; i++) {
            address contributor = contributors[i];
            uint amountToRefund =  contribute[_ID][contributor];
            crow.fundingBalance -= amountToRefund;
            contribute[_ID][contributor] -= amountToRefund;
            payable(contributor).transfer(amountToRefund);
        }
        crow.isActive = false;

    }

    function markSuccessful(uint _ID) internal {
        CrowdFund storage crow = crowd[_ID];
        uint _bal = crow.fundingBalance;
        crow.fundingBalance = 0;
        crow.isActive = false;
        payable(crow.owner).transfer(_bal);
       
    } 
    struct Contributors {
        address contributor;
        uint balance;
    }

    function getContributors(uint _ID) external view returns (Contributors[] memory _contributors){
       CrowdFund storage crow = crowd[_ID];
        uint total =crow.contributors.length;

         _contributors = new Contributors[](total);

        for(uint i = 0; i < total; i++) {
            address contributor = crow.contributors[i];
            uint amount  = contribute[_ID][contributor];

            _contributors[i] = Contributors(contributor, amount);
        }
    }

    function getCrowd(uint _id) external view returns(CrowdFund memory _crowd) {
        _crowd = crowd[_id];
    }
}

