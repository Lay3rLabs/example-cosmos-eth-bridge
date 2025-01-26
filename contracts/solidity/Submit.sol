// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {BridgeDeposit} from "./Types.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol"; 

contract Submit is ERC20 {
    mapping(string => uint256) public depositsBySender;

    event Deposit(string indexed sender, address indexed recipient, uint256 amount);

    constructor() ERC20("BridgedLayer", "ELYR") {
    }

    function handleAddPayload(bytes calldata data, bytes calldata) external {
        BridgeDeposit memory deposit = abi.decode(data, (BridgeDeposit));

        address recipient = address(bytes20(bytes(deposit.recipient)));

        _mint(recipient, deposit.amount);

        depositsBySender[deposit.sender] += deposit.amount;

        emit Deposit(deposit.sender, recipient, deposit.amount);
    }
}