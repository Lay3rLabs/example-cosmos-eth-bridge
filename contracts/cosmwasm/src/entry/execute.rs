use anyhow::{anyhow, Result};
use cosmwasm_schema::cw_serde;
use cosmwasm_std::{entry_point, DepsMut, Env, MessageInfo, Response};

use crate::{event::NewDepositEvent, state::push_deposit};

#[cw_serde]
pub enum ExecuteMsg {
    Deposit { recipient: String },
}

#[entry_point]
pub fn execute(deps: DepsMut, _env: Env, info: MessageInfo, msg: ExecuteMsg) -> Result<Response> {
    match msg {
        ExecuteMsg::Deposit { recipient } => {
            let amount = info
                .funds
                .iter()
                .find_map(|coin| {
                    if !coin.amount.is_zero() {
                        Some(coin.amount)
                    } else {
                        None
                    }
                })
                .ok_or_else(|| anyhow!("no funds"))?;

            let id = push_deposit(deps.storage, info.sender.clone(), amount, recipient.clone())?;

            Ok(Response::default().add_event(NewDepositEvent {
                id,
                sender: info.sender,
                amount,
                recipient,
            }))
        }
    }
}
