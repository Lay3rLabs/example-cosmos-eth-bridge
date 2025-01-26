use clap::Parser;

#[derive(Parser)]
#[command(version, about, long_about = None)]
#[allow(clippy::large_enum_variant)]
pub enum Command {
    /// Deploy the cosmwasm contract
    Deploy {},
    /// Deposit funds into the contract
    Deposit {
        recipient: alloy_primitives::Address,
    },
}
