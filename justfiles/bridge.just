bridge:
  @just _bridge

_bridge: 
  @cd cosmos-client && cargo run --release deposit 