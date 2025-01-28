// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

// Imports the "Script" contract from forge-std
import "forge-std/Script.sol";

// Import your Submit contract
import "contracts/solidity/Submit.sol";

// The script contract name is up to you; typically match the file.
contract Deploy is Script {
    function run() external {
        // Start broadcasting using whichever account is active in your keystore
        vm.startBroadcast();

        // Deploy your contract
        Submit submit = new Submit();

        // Stop broadcasting
        vm.stopBroadcast();
    }
}