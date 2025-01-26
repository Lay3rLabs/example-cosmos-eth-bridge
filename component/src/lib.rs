use alloy_sol_macro::sol;
use alloy_sol_types::SolValue;
use bindings::{
    export,
    lay3r::avs::layer_types::{
        TriggerData, TriggerDataCosmosContractEvent, TriggerDataEthContractEvent,
    },
    Guest, TriggerAction,
};
use trigger_contract::event::NewDepositEvent;

mod bindings;

struct Component;

impl Guest for Component {
    fn run(trigger_action: TriggerAction) -> std::result::Result<Vec<u8>, String> {
        match trigger_action.data {
            TriggerData::EthContractEvent(TriggerDataEthContractEvent { .. }) => {}
            TriggerData::CosmosContractEvent(TriggerDataCosmosContractEvent { event, .. }) => {
                if event.ty.as_str() == NewDepositEvent::KEY
                    || event.ty.as_str() == format!("wasm-{}", NewDepositEvent::KEY)
                {
                    let mut amount = None;
                    let mut sender = None;
                    let mut recipient = None;

                    for (key, value) in event.attributes.into_iter() {
                        match key.as_str() {
                            "amount" => amount = Some(value),
                            "sender" => sender = Some(value),
                            "recipient" => recipient = Some(value),
                            _ => {}
                        }
                    }

                    match (amount, sender, recipient) {
                        (Some(amount), Some(sender), Some(recipient)) => {
                            let response = BridgeDeposit {
                                amount: amount
                                    .to_string()
                                    .parse()
                                    .map_err(|e| format!("Failed to parse amount: {}", e))?,
                                sender,
                                recipient,
                            };

                            return Ok(response.abi_encode());
                        }
                        _ => {}
                    }
                }
            }
            TriggerData::Raw(_) => {}
        };

        Ok(Vec::new())
    }
}

sol!("../contracts/solidity/Types.sol",);

export!(Component with_types_in bindings);
