use anyhow::Result;
use cosmwasm_schema::cw_serde;
use cosmwasm_std::{Addr, Order, Storage, Uint128, Uint64};
use cw_storage_plus::{Bound, Map};

use crate::entry::query::{DepositWithId, DepositsResponse};

const DEPOSITS: Map<u64, Deposit> = Map::new("deposits");

#[cw_serde]
pub struct Deposit {
    pub sender: Addr,
    pub amount: Uint128,
    pub recipient: String,
}

pub fn get_deposit(store: &dyn Storage, id: Uint64) -> Result<Deposit> {
    DEPOSITS.load(store, id.u64()).map_err(Into::into)
}

pub fn get_deposits(
    store: &dyn Storage,
    after_id: Option<Uint64>,
    order: Option<Order>,
) -> Result<DepositsResponse> {
    let after_id = after_id.map(|x| x.u64());

    let deposits = DEPOSITS
        .range(
            store,
            after_id.map(Bound::exclusive),
            None,
            order.unwrap_or(Order::Descending),
        )
        .map(|x| {
            x.map(|(id, deposit)| DepositWithId {
                id: id.into(),
                sender: deposit.sender,
                amount: deposit.amount,
                recipient: deposit.recipient
            })
            .map_err(Into::into)
        })
        .collect::<Result<_>>()?;

    Ok(DepositsResponse { deposits })
}

pub fn push_deposit(store: &mut dyn Storage, sender: Addr, amount: Uint128, recipient: String) -> Result<Uint64> {
    let next_index = DEPOSITS
        .keys(store, None, None, Order::Descending)
        .next()
        .unwrap_or(Ok(0))?
        + 1;

    DEPOSITS.save(store, next_index, &Deposit { sender, amount, recipient })?;

    Ok(next_index.into())
}
