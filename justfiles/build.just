build:
    @just build-solidity
    @just build-wasi
    @just build-cosmwasm

build-cosmwasm:
    @if [ "{{ARCH}}" = "arm64" ]; then \
        just _build-cosmwasm cosmwasm/optimizer-arm64:0.16.1; \
    else \
        just _build-cosmwasm cosmwasm/optimizer:0.16.1; \
    fi

_build-cosmwasm IMAGE:
    @rm -rf "{{COSMWASM_OUT_DIR}}"
    @rm -rf ./artifacts
    @mkdir -p "{{COSMWASM_OUT_DIR}}"
    
    @docker run --rm \
        -v "{{REPO_ROOT}}:/code" \
        --mount type=volume,source="{{COSMWASM_OPTIMIZER_CACHE_NAME}}_target",target=/target \
        --mount type=volume,source="{{COSMWASM_OPTIMIZER_CACHE_NAME}}_registry",target=/usr/local/cargo/registry \
        {{IMAGE}} ./contracts/cosmwasm

    @cp ./artifacts/*.wasm "{{COSMWASM_OUT_DIR}}"
    @rm -rf ./artifacts

build-solidity:
    @rm -rf "{{SOLIDITY_OUT_DIR}}"
    @mkdir -p "{{SOLIDITY_OUT_DIR}}"
    forge build --out "{{SOLIDITY_OUT_DIR}}" --contracts ./contracts/solidity --via-ir

build-wasi:
    @rm -rf "{{WASI_OUT_DIR}}"
    @mkdir -p "{{WASI_OUT_DIR}}"
    @cd component && cargo component build --release
    @cp target/wasm32-wasip1/release/*.wasm "{{WASI_OUT_DIR}}/"
