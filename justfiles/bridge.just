bridge:
  @just _bridge

_bridge: 
  @cd cosmos-client && cargo run --release deposit "{{BRIDGE_RECIPIENT}}"
  @echo "Waiting for 3 seconds before checking balance..."
  @sleep 3
  @just bridge-check-funds

bridge-check-funds:
  @just _bridge-check-funds $(cat "{{SUBMIT_HANDLER_ADDRESS_FILEPATH}}")

_bridge-check-funds ERC20_ADDR:
  @echo checking balance of "{{BRIDGE_RECIPIENT}}" on "{{ERC20_ADDR}}"
  cast call {{ERC20_ADDR}} "balanceOf(address)" "{{BRIDGE_RECIPIENT}}" --rpc-url http://localhost:8545  
  
