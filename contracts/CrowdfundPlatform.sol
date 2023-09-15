// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract CrowdfundPlat{

    struct CrowdFund{
        string title; 
        uint256 fundingGoal;
        address owner;
         uint256 durationTime;
        bool isActive;
         uint256 fundingBalance;
         address[] contributors;
        //  uint256 totalContributions;
    }
  
    mapping(uint => CrowdFund) public crowd;
    //mapping of campaignid to address of contributors to amount contributed
    mapping(uint => mapping(address => uint)) public contribute;
    
//    Campaign Creation: Create a function that allows users to propose new campaigns. 
//      Each campaign should have a unique identifier, a title, a funding goal in Ether, a duration, 
//      and an owner address.
    function proposeCampaign(uint _ID, string memory _title, uint256 _fundingGoal, uint256 _durationTime ) external {
       CrowdFund storage crow = crowd[_ID];
       crow.title = _title;
       crow.fundingGoal = _fundingGoal;
       crow.owner = msg.sender;
       crow.durationTime = _durationTime + block.timestamp;
       crow.isActive = true;
    }
    // Contribution Mechanism: Develop a function that allows users to contribute Ether to a specific campaign.
    // Contributors can only contribute if the campaign is active (i.e., within its duration) and not yet funded.
    function contributeEth(uint _ID) external payable{
         CrowdFund storage crow = crowd[_ID];
        require(crow.isActive == true, "not active");
        require(crow.fundingBalance < crow.fundingGoal, "Funded");
        require(block.timestamp <= crow.durationTime, "Not in duration");
        contribute[_ID][msg.sender] += msg.value;
        crow.fundingBalance += msg.value;
        crow.contributors.push(msg.sender);
    }
    function campaignEnds(uint _ID) external {
         CrowdFund storage crow = crowd[_ID];
        require(msg.sender == crow.owner, "Only Campaign owner");
        require(crow.durationTime < block.timestamp, "Time Has not been reached");
        if(crow.fundingBalance < crow.fundingGoal) {
            // to refund everyone because we didn't reach the funding goal
            refundContributors(_ID);
        } else {
            markSuccessful(_ID);
        }


    }
    // Campaign Expiry and Refund: Implement a mechanism that refunds contributors if a campaign does not 
    // reach its funding goal within the specified duration. The refund should be processed automatically 
    // once the campaign duration ends.0
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

    }
    
    // Campaign Completion and Fund Transfer: Create a function that allows the campaign owner to mark a 
    // campaign as successful if it reaches its funding goal. This action should transfer the raised funds
    // to the owner's address.
    function markSuccessful(uint _ID) internal {
        CrowdFund storage crow = crowd[_ID];
        payable(crow.owner).transfer(crow.fundingBalance);
        crow.fundingBalance = 0;
        crow.isActive = false;
    }
}

