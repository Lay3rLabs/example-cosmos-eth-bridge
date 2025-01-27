start-backend:
  @just stop-backend
  @echo "starting Anvil..."
  @anvil > /dev/null 2>&1 &
  @echo "setting up cosmos..."
  @just _setup-cosmos > /dev/null 2>&1
  @echo "starting cosmos..."
  @just _run-cosmos > /dev/null 2>&1 &
  @echo "waiting a few seconds before starting WAVS..."
  @sleep 3
  @wavs --home=./config > /dev/null &
  @echo "done!"

stop-backend:
  @-just _clean-cosmos > /dev/null 2>&1
  @-just _clean-wavs > /dev/null 2>&1
  @-killall -9 anvil > /dev/null 2>&1

_clean-wavs:
  -killall -9 wavs
  rm -rf ./.wavs-data

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