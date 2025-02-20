use anyhow::{anyhow, Error};
use cosmwasm_std::{Addr, Event, Uint128, Uint64};

#[derive(Debug)]
pub struct NewDepositEvent {
    pub sender: Addr,
    pub recipient: String,
    pub amount: Uint128,
    pub id: Uint64,
}

impl NewDepositEvent {
    pub const KEY: &'static str = "new-deposit";
}

impl From<NewDepositEvent> for Event {
    fn from(src: NewDepositEvent) -> Self {
        Event::new(NewDepositEvent::KEY).add_attributes(vec![
            ("id", src.id.to_string()),
            ("amount", src.amount.to_string()),
            ("sender", src.sender.to_string()),
            ("recipient", src.recipient.to_string()),
        ])
    }
}

impl TryFrom<Event> for NewDepositEvent {
    type Error = Error;

    fn try_from(evt: Event) -> anyhow::Result<Self> {
        if evt.ty.as_str() != format!("wasm-{}", NewDepositEvent::KEY)
            && evt.ty.as_str() != NewDepositEvent::KEY
        {
            return Err(anyhow!(
                "unexpected event type: {}, should be {}",
                evt.ty,
                NewDepositEvent::KEY
            ));
        }

        let mut id = None;
        let mut sender = None;
        let mut amount = None;
        let mut recipient = None;

        for attr in evt.attributes.into_iter() {
            match attr.key.as_str() {
                "id" => id = Some(Uint64::new(attr.value.parse()?)),
                "amount" => amount = Some(Uint128::new(attr.value.parse()?)),
                "sender" => sender = Some(Addr::unchecked(attr.value)),
                "recipient" => recipient = Some(attr.value),
                _ => {}
            }
        }

        match (id, sender, amount, recipient) {
            (Some(id), Some(sender), Some(amount), Some(recipient)) => Ok(NewDepositEvent {
                id,
                sender,
                amount,
                recipient,
            }),
            _ => Err(anyhow!("missing required attributes")),
        }
    }
}
