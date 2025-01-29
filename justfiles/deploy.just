deploy:
    @just deploy-cosmos
    @just deploy-ethereum
    @just deploy-service

deploy-cosmos:
    @cd cosmos-client && cargo run --release deploy 2>&1 > /dev/null

deploy-ethereum:
    @just _deploy-eigen-core
    @just _deploy-eigen-handler
    @just _deploy-eigen-manager

_deploy-eigen-core:
    @wavs-cli deploy-eigen-core --home ./config --chain anvil --eth-mnemonic "{{ETHEREUM_MNEMONIC}}"

_deploy-eigen-handler:
    @rm -rf broadcast
    @forge script handler-deploy/DeployHandler.s.sol:Deploy \
        --rpc-url "{{ETHEREUM_RPC_URL}}" \
        --sig "run(string calldata mnemonic)" "{{ETHEREUM_MNEMONIC}}" \
        --broadcast \
        --json 2>&1 > /dev/null
    @cat broadcast/DeployHandler.s.sol/31337/run-latest.json | jq -r '.transactions[0].contractAddress' | tr -d '\n' > "{{SUBMIT_HANDLER_ADDRESS_FILEPATH}}"

_deploy-eigen-manager:
    @wavs-cli deploy-eigen-service-manager --home ./config --chain anvil --eth-mnemonic "{{ETHEREUM_MNEMONIC}}" \
        --service-handler $(cat "{{SUBMIT_HANDLER_ADDRESS_FILEPATH}}")

deploy-service:
    @just _deploy-service-inner \
        $(cat "{{TRIGGER_ADDRESS_FILEPATH}}") \
        $(cat "{{CLI_DEPLOYMENTS_FILEPATH}}" | jq -r '.eigen_service_managers.anvil[-1]')

_deploy-service-inner TRIGGER_ADDRESS SUBMIT_ADDRESS:
    @echo ""
    @echo "*** deploying service at trigger addess {{TRIGGER_ADDRESS}} and submit address {{SUBMIT_ADDRESS}} ***"
    @wavs-cli deploy-service \
        --home ./config \
        --trigger-chain wasmd \
        --trigger cosmos-contract-event \
        --trigger-event-name "{{TRIGGER_EVENT_NAME}}" \
        --trigger-address "{{TRIGGER_ADDRESS}}" \
        --component "{{justfile_directory()}}/{{WASI_OUT_DIR}}/bridge.wasm" \
        --submit-chain anvil \
        --submit-address "{{SUBMIT_ADDRESS}}" \
        --eth-mnemonic "{{ETHEREUM_MNEMONIC}}" \
        --cosmos-mnemonic "{{COSMOS_MNEMONIC}}" \