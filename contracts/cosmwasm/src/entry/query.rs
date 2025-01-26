use anyhow::Result;
use cosmwasm_schema::{cw_serde, QueryResponses};
use cosmwasm_std::{
    entry_point, to_json_binary, Addr, Deps, Env, Order, QueryResponse, Uint128, Uint64,
};

use crate::state::{get_deposit, get_deposits};

#[cw_serde]
#[derive(QueryResponses)]
pub enum QueryMsg {
    #[returns(DepositsResponse)]
    Deposits {
        after_id: Option<Uint64>,
        // default is [Order::Descending]
        order: Option<Order>,
    },

    #[returns(crate::state::Deposit)]
    Deposit { id: Uint64 },
}

#[cw_serde]
pub struct DepositWithId {
    pub id: Uint64,
    pub sender: Addr,
    pub amount: Uint128,
}

#[cw_serde]
pub struct DepositsResponse {
    pub deposits: Vec<DepositWithId>,
}

#[entry_point]
pub fn query(deps: Deps, _env: Env, msg: QueryMsg) -> Result<QueryResponse> {
    match msg {
        QueryMsg::Deposits { after_id, order } => {
            to_json_binary(&get_deposits(deps.storage, after_id, order)?)
        }
        QueryMsg::Deposit { id } => {
            let deposit = get_deposit(deps.storage, id)?;
            to_json_binary(&deposit)
        }
    }
    .map_err(|e| e.into())
}
