// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "../src/AcademicChain.sol";

contract DeployAcademicChain is Script {
    function run() external {
        // Start broadcasting transactions
        vm.startBroadcast();

        // Deploy the contract
        AcademicChain academicChain = new AcademicChain();
        
        // Stop broadcasting
        vm.stopBroadcast();

        // Log the deployed address
        console.log("AcademicChain deployed to:", address(academicChain));
    }
}