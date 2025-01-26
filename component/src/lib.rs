use bindings::{export, lay3r::avs::layer_types::{TriggerData, TriggerDataCosmosContractEvent, TriggerDataEthContractEvent}, Guest, TriggerAction};

mod bindings;

// use layer_wasi::{
//     bindings::{compat::{TriggerAction, TriggerData, TriggerDataCosmosContractEvent, TriggerDataEthContractEvent}, world::Guest},
//     export_layer_trigger_world,
// };

struct Component;

impl Guest for Component {
    fn run(trigger_action: TriggerAction) -> std::result::Result<Vec<u8>, String> {
        let data = match trigger_action.data {
            TriggerData::EthContractEvent(TriggerDataEthContractEvent{..}) => {
                //TODO
                Vec::new()
            },
            TriggerData::CosmosContractEvent(TriggerDataCosmosContractEvent{..}) => {
                //TODO
                Vec::new()
            },
            TriggerData::Raw(data) => data,
        };

        Ok(data)
    }
}

export!(Component with_types_in bindings);