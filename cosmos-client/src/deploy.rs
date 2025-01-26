use anyhow::{Context, Result};
use layer_climb::prelude::*;
use trigger_contract::entry::instantiate::InstantiateMsg;

use crate::WORKSPACE_PATH;

pub async fn run(client: SigningClient) -> Result<()> {
    tracing::info!("Deploying contracts...");

    let contract_dir_path = WORKSPACE_PATH
        .join(".build-artifacts")
        .join("cosmos-contracts");
    let trigger_address_file_path = contract_dir_path.join("trigger.address");
    let contract_file_path = contract_dir_path.join("trigger_contract.wasm");

    if trigger_address_file_path.exists() {
        std::fs::remove_file(&trigger_address_file_path).context(format!(
            "Failed to delete {}",
            trigger_address_file_path.display()
        ))?;
    }

    let bytes = std::fs::read(&contract_file_path)
        .context(format!("Failed to read {}", contract_file_path.display()))?;

    let (code_id, _) = client.contract_upload_file(bytes, None).await?;

    tracing::debug!("Contract code id: {}", code_id);

    let (contract_addr, _) = client
        .contract_instantiate(
            None,
            code_id,
            "trigger",
            &InstantiateMsg {},
            Vec::new(),
            None,
        )
        .await?;

    tracing::info!("Deployed trigger contract at {}", contract_addr);

    std::fs::write(&trigger_address_file_path, contract_addr.to_string()).context(format!(
        "Failed to write to {}",
        trigger_address_file_path.display()
    ))?;

    Ok(())
}
