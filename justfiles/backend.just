start-backend:
  @just _start-cosmos > /dev/null 2>&1 &
  @just _start-wavs > /dev/null 2>&1 &
  @anvil > /dev/null 2>&1 &

stop-backend:
  @-just _clean-cosmos > /dev/null 2>&1
  @-just _clean-wavs > /dev/null 2>&1
  @-killall -9 anvil > /dev/null 2>&1

_start-wavs:
  just _clean-wavs
  wavs --home=./config &

_clean-wavs:
  -killall -9 wavs
  rm -rf ./.wavs-data

_start-cosmos:
  just _clean-cosmos
  just _setup-cosmos
  just _run-cosmos

_setup-cosmos:
  docker run --rm \
  --name "{{COSMOS_DOCKER_NAME}}" \
  --mount "type=volume,source={{COSMOS_DOCKER_NAME}}_data,target=/root" \
  --env "CHAIN_ID={{COSMOS_CHAIN_ID}}" \
  --env "FEE_TOKEN={{COSMOS_GAS_DENOM}}" \
  cosmwasm/wasmd:latest \
  /opt/setup_wasmd.sh \
  {{COSMOS_ADDRESS}}

  docker run --rm \
  --name "{{COSMOS_DOCKER_NAME}}" \
  --mount "type=volume,source={{COSMOS_DOCKER_NAME}}_data,target=/root" \
  cosmwasm/wasmd:latest \
  sed -E -i "/timeout_(propose|prevote|precommit|commit)/s/[0-9]+m?s/{{COSMOS_BLOCK_TIME}}/" /root/.wasmd/config/config.toml

_run-cosmos:
  docker run --rm \
  --name "{{COSMOS_DOCKER_NAME}}" \
  --mount "type=volume,source={{COSMOS_DOCKER_NAME}}_data,target=/root" \
  --publish 26657:26657 \
  --publish 26656:26656 \
  --publish 1317:1317 \
  --publish 9090:9090 \
  cosmwasm/wasmd:latest \
  /opt/run_wasmd.sh

_clean-cosmos:
  -docker kill "{{COSMOS_DOCKER_NAME}}"
  -docker rm "{{COSMOS_DOCKER_NAME}}"
  -docker volume rm -f "{{COSMOS_DOCKER_NAME}}_data"