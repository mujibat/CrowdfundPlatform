# CrowdfundPlat Smart Contract

This is a Solidity smart contract for managing crowdfunding campaigns. The contract allows users to propose new campaigns, contribute Ether to campaigns, and handles campaign expiration and fund transfer. Below, you'll find an overview of the contract's functionality and usage.

## Table of Contents
- [Overview](#overview)
- [Usage](#usage)
  - [Campaign Creation](#campaign-creation)
  - [Contribution Mechanism](#contribution-mechanism)
  - [Campaign Expiry and Refund](#campaign-expiry-and-refund)
  - [Campaign Completion and Fund Transfer](#campaign-completion-and-fund-transfer)
- [License](#license)

## Overview

The `CrowdfundPlat` smart contract manages crowdfunding campaigns with the following features:

- **Campaign Creation:** Users can propose new campaigns with unique identifiers, titles, funding goals in Ether, durations, and owner addresses.

- **Contribution Mechanism:** Users can contribute Ether to specific campaigns. Contributions are allowed only if the campaign is active (within its duration) and has not reached its funding goal.

- **Campaign Expiry and Refund:** If a campaign does not reach its funding goal within the specified duration, contributors are automatically refunded. The refund is processed when the campaign duration ends.

- **Campaign Completion and Fund Transfer:** Campaign owners can mark a campaign as successful if it reaches its funding goal. This action transfers the raised funds to the owner's address.

## Usage

### Campaign Creation

To create a new campaign, use the `proposeCampaign` function:

```solidity
function proposeCampaign(uint _ID, string memory _title, uint256 _fundingGoal, uint256 _durationTime) external
```

- `_ID`: Unique identifier for the campaign.
- `_title`: Title of the campaign.
- `_fundingGoal`: Funding goal in Ether.
- `_durationTime`: Duration of the campaign in seconds.

### Contribution Mechanism

To contribute Ether to a campaign, use the `contributeEth` function:

```solidity
function contributeEth(uint _ID) external payable
```

- `_ID`: Identifier of the campaign you want to contribute to.

### Campaign Expiry and Refund

Campaign expiration and refund are handled automatically. If a campaign does not reach its funding goal within the specified duration, contributors are refunded. No manual action is required.

### Campaign Completion and Fund Transfer

To mark a campaign as successful and transfer the raised funds to the owner's address, use the `campaignEnds` function:

```solidity
function campaignEnds(uint _ID) external
```

- `_ID`: Identifier of the campaign to mark as successful.
