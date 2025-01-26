use std::path::PathBuf;

use layer_climb::prelude::*;
use anyhow::{Result, Context, anyhow};
use trigger_contract::entry::execute::ExecuteMsg;

use crate::WORKSPACE_PATH;

pub async fn run(client: SigningClient) -> Result<()> {

    let meta = Meta::load(client.querier.chain_config.clone())?;
    let coin = new_coin(1, &client.querier.chain_config.gas_denom);

    tracing::info!("Sending deposit to contract {} (for service id {})", meta.trigger_address, meta.service_id);

    let tx = client.contract_execute(&meta.trigger_address, &ExecuteMsg::Deposit { }, vec![coin], None).await?;

    tracing::info!("Sent! Tx hash: {}", tx.txhash);

    Ok(())
}

#[derive(Debug)]
struct Meta {
    pub service_id: String,
    pub trigger_address: Address,
}

impl Meta {
    pub fn load(chain_config: ChainConfig) -> Result<Self> {
        fn read_to_string(path: PathBuf) -> Result<String> {
            let bytes = std::fs::read(&path).context(format!("Failed to read {}", path.display()))?;
            let s = String::from_utf8(bytes).expect(format!("Failed to read {}", path.display()).as_str()).trim().to_string();
            if s.is_empty() {
                return Err(anyhow!("Failed to read {}", path.display()));
            }

            Ok(s)
        }

        let service_id = read_to_string(WORKSPACE_PATH.join(".build-artifacts").join("service.id"))?;
        let trigger_address = read_to_string(WORKSPACE_PATH.join(".build-artifacts").join("cosmos-contracts").join("trigger.address"))?;

        Ok(Self {
            service_id,
            trigger_address: chain_config.parse_address(&trigger_address)?,
        })
    }
}