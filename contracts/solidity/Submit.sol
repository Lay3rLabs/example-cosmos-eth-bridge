// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BridgeDeposit} from "./Types.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 
import {ILayerServiceManager} from "@layer/interfaces/ILayerServiceManager.sol";
import {ILayerServiceHandler} from "@layer/interfaces/ILayerServiceHandler.sol";

contract Submit is ERC20,ILayerServiceHandler {
    ILayerServiceManager private _serviceManager;
    mapping(string => uint256) public depositsBySender;

    event Deposit(string indexed sender, address indexed recipient, uint256 amount);

    constructor(ILayerServiceManager serviceManager) ERC20("BridgedLayer", "ELYR") {
        _serviceManager = serviceManager;
    }

    function handleSignedData(bytes calldata data, bytes calldata signature) external {
        _serviceManager.validate(data, signature);

        BridgeDeposit memory deposit = abi.decode(data, (BridgeDeposit));

        _mint(deposit.recipient, deposit.amount);

        depositsBySender[deposit.sender] += deposit.amount;

        emit Deposit(deposit.sender, deposit.recipient, deposit.amount);
    }
}