// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import { CrowdfundPlat } from "../src/CrowdfundPlatform.sol";

contract CrowdfundPlatScript is Script {
    function setUp() public {}

    function run() public {
        uint privateKey = vm.envUint("PRIVATEKEY");
        address account = vm.addr(privateKey);
        console2.logAddress(account);
        vm.startBroadcast(privateKey);
        CrowdfundPlat crowdfundplat = new CrowdfundPlat(); 
        // crowdfundPlat.proposeCampaign('Dol', '15 ether', 0);
        vm.stopBroadcast(); 
    }
} 