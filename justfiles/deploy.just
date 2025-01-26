# A bit messy, but it's just running commands and parsing the commandline output

deploy:
    @just deploy-cosmos
    @just deploy-ethereum
    @just deploy-service
    @just deploy-report

deploy-cosmos:
    @cd cosmos-client && cargo run --release deploy 2>&1 > /dev/null

deploy-ethereum:
    @just _deploy-eigen-core
    @just _deploy-eigen-handler
    @just _deploy-eigen-manager

_deploy-eigen-core:
    @wavs-cli deploy-eigen-core --home ./config --chain anvil --eth-mnemonic "{{ETHEREUM_MNEMONIC}}" 2>&1 > /dev/null

_deploy-eigen-handler:
    @echo $(just _deploy-eigen-handler-inner 2>&1 | awk '/Deployed to:/ { print $3 }') > "{{SUBMIT_HANDLER_ADDRESS_FILEPATH}}"

_deploy-eigen-handler-inner:
    forge create ./contracts/solidity/Submit.sol:Submit \
        --via-ir \
        --broadcast \
        --keystore ./config/foundry-keystore \
        --password layer-anvil \
        --rpc-url http://localhost:8545 

_deploy-eigen-manager:
    @echo $(just _deploy-eigen-manager-inner 2>&1 | awk '/Submit contract:/ { print $5 }') > "{{SUBMIT_MANAGER_ADDRESS_FILEPATH}}"

_deploy-eigen-manager-inner:
    wavs-cli deploy-eigen-service-manager --home ./config --chain anvil --eth-mnemonic "{{ETHEREUM_MNEMONIC}}" \
        --service-handler $(cat "{{SUBMIT_HANDLER_ADDRESS_FILEPATH}}" | tr -d '\n' )

deploy-service:
    @just _deploy-service-inner $(cat "{{TRIGGER_ADDRESS_FILEPATH}}" | tr -d '\n' ) $(cat "{{SUBMIT_MANAGER_ADDRESS_FILEPATH}}" | tr -d '\n' )

_deploy-service-inner TRIGGER_ADDRESS SUBMIT_ADDRESS:
    @echo $(just _deploy-service-inner-cmd {{TRIGGER_ADDRESS}} {{SUBMIT_ADDRESS}} 2>&1 | awk '/Service ID:/ { print $5 }') > "{{SERVICE_ID_FILEPATH}}"

_deploy-service-inner-cmd TRIGGER_ADDRESS SUBMIT_ADDRESS:
    @echo ""
    @echo "*** deploying service at trigger addess {{TRIGGER_ADDRESS}} and submit address {{SUBMIT_ADDRESS}} ***"
    wavs-cli deploy-service \
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

deploy-report: 
    @just _deploy-report-cleanup \
        $(cat "{{TRIGGER_ADDRESS_FILEPATH}}" | tr -d '\n' ) \
        $(cat "{{SUBMIT_HANDLER_ADDRESS_FILEPATH}}" | tr -d '\n' ) \
        $(cat "{{SUBMIT_MANAGER_ADDRESS_FILEPATH}}" | tr -d '\n' ) \
        $(cat "{{SERVICE_ID_FILEPATH}}" | tr -d '\n' )

    @just _deploy-report-inner \
        $(cat "{{TRIGGER_ADDRESS_FILEPATH}}") \
        $(cat "{{SUBMIT_HANDLER_ADDRESS_FILEPATH}}") \
        $(cat "{{SUBMIT_MANAGER_ADDRESS_FILEPATH}}") \
        $(cat "{{SERVICE_ID_FILEPATH}}")

_deploy-report-cleanup TRIGGER_ADDRESS SUBMIT_HANDLER_ADDRESS SUBMIT_MANAGER_ADDRESS SERVICE_ID:
    @echo "{{TRIGGER_ADDRESS}}" > "{{TRIGGER_ADDRESS_FILEPATH}}"
    @echo "{{SUBMIT_HANDLER_ADDRESS}}" > "{{SUBMIT_HANDLER_ADDRESS_FILEPATH}}"
    @echo "{{SUBMIT_MANAGER_ADDRESS}}" > "{{SUBMIT_MANAGER_ADDRESS_FILEPATH}}"
    @echo "{{SERVICE_ID}}" > "{{SERVICE_ID_FILEPATH}}"

_deploy-report-inner TRIGGER_ADDRESS SUBMIT_HANDLER_ADDRESS SUBMIT_MANAGER_ADDRESS SERVICE_ID:
    @echo "Trigger Address: {{TRIGGER_ADDRESS}}"
    @echo "Submit Handler Address: {{SUBMIT_HANDLER_ADDRESS}}"
    @echo "Submit Manager Address: {{SUBMIT_MANAGER_ADDRESS}}"
    @echo "Service ID: {{SERVICE_ID}}"