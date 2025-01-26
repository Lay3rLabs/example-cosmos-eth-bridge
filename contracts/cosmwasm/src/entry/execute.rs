use anyhow::{anyhow, Result};
use cosmwasm_schema::cw_serde;
use cosmwasm_std::{entry_point, DepsMut, Env, MessageInfo, Response};

use crate::{event::NewDepositEvent, state::push_deposit};

#[cw_serde]
pub enum ExecuteMsg {
    Deposit { },
}

#[entry_point]
pub fn execute(deps: DepsMut, _env: Env, info: MessageInfo, msg: ExecuteMsg) -> Result<Response> {
    match msg {
        ExecuteMsg::Deposit { } => {
            let amount = cw_utils::must_pay(&info, "ulayer").map_err(|e| anyhow!("{:?}", e))?;
            let id = push_deposit(deps.storage, info.sender.clone(), amount)?;

            Ok(Response::default().add_event(NewDepositEvent {
                id,
                sender: info.sender,
                amount
            }))
        }
    }
}
