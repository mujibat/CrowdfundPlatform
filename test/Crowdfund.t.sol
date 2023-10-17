// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
import {CrowdfundPlat} from "../src/CrowdfundPlatform.sol";
import "./Helpers.sol";

contract CrowdfundPlatTest is Helpers {
    CrowdfundPlat crowdfund;
    CrowdfundPlat.CrowdFund _crowdfund;
    address _userA;
    address _userB;

    uint256 _privKeyA;
    uint256 _privKeyB;

    function setUp() public {
        crowdfund = new CrowdfundPlat();
        (_userA, _privKeyA) = mkaddr("USERA");
        (_userB, _privKeyB) = mkaddr("USERB");
        // _crowdfund.title = "";
        // _crowdfund.fundingGoal = 10 ether;
        //     _crowdfund.owner = _userA;
        //     _crowdfund.durationTime = 0;
        //     _crowdfund.isActive = true;
        //     _crowdfund.fundingBalance = 2 ether;
    }

    function testProposeCampaign() public {
        vm.startPrank(_userB);
        _crowdfund.title = "Dolapo";
        _crowdfund.fundingGoal = 15 ether;
        _crowdfund.durationTime = 12 hours;
        _crowdfund.isActive = true;
        crowdfund.proposeCampaign(
            _crowdfund.title,
            _crowdfund.fundingGoal,
            _crowdfund.durationTime
        );
    }

    function testNotAmount() public {
        vm.startPrank(_userB);
        vm.expectRevert(CrowdfundPlat.InsufficientInput.selector);
        uint id = 1;
        crowdfund.contributeEth{value: 0 ether}(id);
        vm.stopPrank();
    }

    function testNotActive() public {
        uint id = 1;
        vm.expectRevert(CrowdfundPlat.NotActive.selector);
        crowdfund.contributeEth{value: 4 ether}(id);
    }

    function testFundingGoalAchieved() public {
        uint id = 1;
        _crowdfund.title = "Dolapo";
        _crowdfund.fundingGoal = 15 ether;
        _crowdfund.durationTime = 12 hours;
        crowdfund.proposeCampaign(
            _crowdfund.title,
            _crowdfund.fundingGoal,
            _crowdfund.durationTime
        );
        vm.expectRevert(CrowdfundPlat.ExceededFundingGoal.selector);
        crowdfund.contributeEth{value: 20 ether}(id);
    }

    function testNotInDuration() public {
        uint id = 1;
        _crowdfund.fundingGoal = 15 ether;
        _crowdfund.fundingBalance = 17 ether;
        _crowdfund.durationTime = block.timestamp + 10 minutes;
             crowdfund.proposeCampaign(
            _crowdfund.title,
            _crowdfund.fundingGoal,
            _crowdfund.durationTime
        );
         vm.warp(15 minutes);
        vm.expectRevert(CrowdfundPlat.NotInDuration.selector);
        crowdfund.contributeEth{value: 4 ether}(id);
    }
    function testContributeEth() public {
        uint id = 1;
        _crowdfund.title = "Dolapo";
        _crowdfund.fundingGoal = 15 ether;
        _crowdfund.durationTime = 12 hours;
        crowdfund.proposeCampaign(
            _crowdfund.title,
            _crowdfund.fundingGoal,
            _crowdfund.durationTime
        );
        crowdfund.contributeEth{value: 14 ether}(id);
        assertEq(crowdfund.getCrowd(1).fundingBalance, 14 ether);
    }

    function testNotActiveCampaignEnds() public {
        uint id = 1;
        vm.expectRevert(CrowdfundPlat.NotActive.selector);
        crowdfund.campaignEnds(id);
    }

    function testNotOwner() public {
         vm.startPrank(_userA);
        uint id = 1;
        crowdfund.proposeCampaign(
            _crowdfund.title,
            _crowdfund.fundingGoal,
            _crowdfund.durationTime
        );
        vm.stopPrank();
         vm.prank(address(0x1111));
        vm.expectRevert(CrowdfundPlat.NotOwner.selector);
        crowdfund.campaignEnds(id);
    }

    function testTimeNotReached() public {
        uint id = 1;
        _crowdfund.durationTime = 12 hours;
        crowdfund.proposeCampaign(
            _crowdfund.title,
            _crowdfund.fundingGoal,
            _crowdfund.durationTime
        );
        vm.expectRevert(CrowdfundPlat.TimeNotReached.selector);
        crowdfund.campaignEnds(id);
    }

    function testCampaignEnds() public {
        vm.startPrank(_userB);
          crowdfund.proposeCampaign(
            'Dolapo',
            15 ether,
            0
        );
        vm.startPrank(address(0x1111));
        vm.deal(address(0x1111), 15 ether);
        crowdfund.contributeEth{value: 15 ether}(1);
        vm.startPrank(_userB);
        uint balb4 = _userB.balance;
        assertEq(crowdfund.getCrowd(1).fundingBalance, 15 ether);
        crowdfund.campaignEnds(1);
        assertEq(_userB.balance - balb4, 15 ether);
    }

    //test if refundContributors was external

    function testRefundContributors() public {
        vm.startPrank(_userB);
        uint id = 1;
        crowdfund.proposeCampaign("Dolapo", 15 ether, 0);
        assertEq(crowdfund.getCrowd(1).title, "Dolapo");
        vm.stopPrank();

        hoax(address(0x1111), 5 ether);
        crowdfund.contributeEth{value: 5 ether}(1);

        assertEq(crowdfund.getCrowd(1).fundingBalance, 5 ether);
        vm.startPrank(_userB);
        uint balB4 = address(0x1111).balance;
        crowdfund.campaignEnds(id);
         assertEq(crowdfund.getCrowd(1).fundingBalance, 0);
         assertEq(address(0x1111).balance - balB4 , 5 ether);
        
    }
    //test if markSuccessful was external or public
    function testMarkSuccessful() public {
        vm.startPrank(_userB);
        uint id = 1;
        crowdfund.proposeCampaign("Dolapo", 15 ether, 0);
        assertEq(crowdfund.getCrowd(1).title, "Dolapo");
        vm.stopPrank();
        hoax(address(0x1111), 15 ether);
        crowdfund.contributeEth{value: 15 ether}(1);

        assertEq(crowdfund.getCrowd(1).fundingBalance, 15 ether);
        vm.startPrank(_userB);
        uint balB4 = address(_userB).balance;
        crowdfund.campaignEnds(id);
         assertEq(crowdfund.getCrowd(1).fundingBalance, 0);
         assertEq(address(_userB).balance - balB4 , 15 ether);
    }


function testGetContributors() public {
          vm.startPrank(_userB);
        crowdfund.proposeCampaign("Dolapo", 15 ether, 0);
        vm.stopPrank();
        hoax(address(0x1111), 15 ether);
        crowdfund.contributeEth{value: 3 ether}(1);
        hoax(address(0x2222), 15 ether);
        crowdfund.contributeEth{value: 5 ether}(1);
        crowdfund.getContributors(1);

}
}
