mod args;
mod deploy;
mod deposit;

use anyhow::{anyhow, Result};
use args::Command;
use clap::Parser;
use layer_climb::prelude::*;
use layer_climb::signing::SigningClient;
use serde::{Deserialize, Serialize};
use std::{collections::BTreeMap, path::PathBuf, sync::LazyLock};
use tracing::level_filters::LevelFilter;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt, Layer};

// Corresponds to COSMOS_ADDRESS in `vars.just`
// this is just some randomly generated address
const COSMOS_MNEMONIC:&str = "couch surprise bamboo what penalty farm ocean company basic hire inject oak emerge shed dish round collect boat error reunion size holiday cup skill";

pub static WORKSPACE_PATH: LazyLock<PathBuf> = LazyLock::new(|| {
    PathBuf::from(std::env::var("CARGO_MANIFEST_DIR").expect("CARGO_MANIFEST_DIR should be set"))
        .parent()
        .unwrap()
        .to_path_buf()
});

#[tokio::main]
async fn main() -> Result<()> {
    tracing_subscriber::registry()
        .with(
            tracing_subscriber::fmt::layer()
                .without_time()
                .with_target(false)
                .with_filter(if cfg!(debug_assertions) {
                    LevelFilter::DEBUG
                } else {
                    LevelFilter::INFO
                }),
        )
        .try_init()
        .unwrap();

    let command = Command::parse();

    let config_path = WORKSPACE_PATH.join("config").join("wavs.toml");
    let wavs_config: WavsConfig =
        toml::from_str(&std::fs::read_to_string(config_path).unwrap()).unwrap();

    let signer = KeySigner::new_mnemonic_str(COSMOS_MNEMONIC, None)?;
    let signing_client = SigningClient::new(
        wavs_config
            .chains
            .cosmos
            .get("wasmd")
            .unwrap()
            .clone()
            .into(),
        signer,
        None,
    )
    .await?;

    tracing::info!("Client address: {}", signing_client.addr);

    let balance = signing_client
        .querier
        .balance(signing_client.addr.clone(), None)
        .await?
        .unwrap_or_default();

    if balance == 0 {
        return Err(anyhow!("not enough funds"));
    }

    match command {
        Command::Deploy {} => {
            deploy::run(signing_client).await?;
        }
        Command::Deposit { recipient } => {
            deposit::run(signing_client, recipient).await?;
        }
    }

    Ok(())
}

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct WavsConfig {
    pub chains: ChainConfigs,
}

#[derive(Debug, Deserialize, Serialize, Clone, Default)]
pub struct ChainConfigs {
    pub cosmos: BTreeMap<String, CosmosChainConfig>,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
pub struct CosmosChainConfig {
    pub chain_id: String,
    pub bech32_prefix: String,
    pub rpc_endpoint: Option<String>,
    pub grpc_endpoint: Option<String>,
    pub gas_price: f32,
    pub gas_denom: String,
}

impl From<CosmosChainConfig> for ChainConfig {
    fn from(config: CosmosChainConfig) -> Self {
        Self {
            chain_id: ChainId::new(config.chain_id),
            rpc_endpoint: config.rpc_endpoint,
            grpc_endpoint: config.grpc_endpoint,
            grpc_web_endpoint: None,
            gas_price: config.gas_price,
            gas_denom: config.gas_denom,
            address_kind: AddrKind::Cosmos {
                prefix: config.bech32_prefix,
            },
        }
    }
}
