# General
ARCH := `uname -m`
REPO_ROOT := `git rev-parse --show-toplevel`

# CLI
COSMOS_MNEMONIC := "couch surprise bamboo what penalty farm ocean company basic hire inject oak emerge shed dish round collect boat error reunion size holiday cup skill"
ETHEREUM_MNEMONIC := "test test test test test test test test test test test junk"

# Backend

COSMOS_ADDRESS := "wasm1t8xljxdcjnvtfqpfxu9phdmsmcrf3n9fftexjp" # Corresponds to COSMOS_MNEMONIC 
COSMOS_DOCKER_NAME := "layer-example-wasmd"
COSMOS_BLOCK_TIME := "200ms"
COSMOS_CHAIN_ID := "layer-wasmd"
COSMOS_GAS_DENOM := "ulayer"

# Contracts

COSMWASM_OUT_DIR := ".build-artifacts/cosmos-contracts" 
COSMWASM_OPTIMIZER_CACHE_NAME := "cosmos-eth-bridge"
SOLIDITY_OUT_DIR := ".build-artifacts/ethereum-contracts" 

# Components

WASI_OUT_DIR := ".build-artifacts/wasi-components" 

# Services
TRIGGER_ADDRESS_FILEPATH := ".build-artifacts/cosmos-contracts/trigger.address"
SUBMIT_HANDLER_ADDRESS_FILEPATH := ".build-artifacts/ethereum-contracts/submit-handler.address"
SUBMIT_MANAGER_ADDRESS_FILEPATH := ".build-artifacts/ethereum-contracts/submit-manager.address"
SERVICE_ID_FILEPATH := ".build-artifacts/service.id"
TRIGGER_EVENT_NAME := "new-deposit"