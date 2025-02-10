// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "forge-std/Script.sol";
import "contracts/solidity/Submit.sol";
import {ILayerServiceManager} from "@wavs/interfaces/ILayerServiceManager.sol";

contract Deploy is Script {
    function run(string calldata mnemonic, string calldata serviceManager) external {
        (address deployerAddr,) = deriveRememberKey(mnemonic, 0);

        vm.startBroadcast(deployerAddr);

        new Submit(ILayerServiceManager(vm.parseAddress(serviceManager)));

        vm.stopBroadcast();
    }
}