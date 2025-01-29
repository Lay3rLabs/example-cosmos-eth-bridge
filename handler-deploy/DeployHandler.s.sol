// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "contracts/solidity/Submit.sol";

contract Deploy is Script {
    function run(string calldata mnemonic) external {
        (address deployerAddr,) = deriveRememberKey(mnemonic, 0);

        vm.startBroadcast(deployerAddr);

        new Submit();

        vm.stopBroadcast();
    }
}