# Layer AVS Cosmos -> Eth Bridge Example

_Currently depends on building WAVS from this PR: https://github.com/Lay3rLabs/WAVS/pull/323_

## One-time setup

1. **install the openzeppelin contract dependencies**

```bash
npm install
```



2. **Follow the [Native Install](https://github.com/Lay3rLabs/WAVS/blob/main/docs/QUICKSTART.md#running-natively) instructions on WAVS if you haven't done so already.**

Short version:

```bash
git clone https://github.com/Lay3rLabs/WAVS.git ~/WAVS

cd ~/WAVS && just install-native ~/wavs-config ~/wavs-data
```

_Docker won't work out of the box here because we need WAVS to listen to a local Cosmos chain we'll be running_

3. **Build all the contracts and components**

```bash
just build
```

4. Install any other generic tooling that pops up... e.g. [just](https://github.com/casey/just), [foundry](https://book.getfoundry.sh/getting-started/installation), [docker](https://www.docker.com/) etc.

That's it!

## Up and running

1. **Start the backend**

```bash
just start-backend
```

_tip: wait until these are ready before proceeding:_

- Hitting http://localhost:8000/info shows a list of operators
- Hitting http://localhost:26657/status shows a valid cosmos status 

This may take some time if you've never started the backend before, but subsequent start-ups should be quick.

2. **Deploy contracts and services**

```bash
just deploy
```

This may take some time if you've never deployed before, but subsequent deployments should be quick.

3. **Bridge assets**

```bash
just bridge
```

You'll see it do some stuff and then print out your balance. 

4. **Stop the backend**

```bash
just stop-backend
```

# Implementation notes

Almost everyting is in the [justfiles](justfiles)
A minimal cosmos client is in [cosmos-client](cosmos-client)

Overall flow when running `just bridge` is:

1. (user action) sending some `ulayer` to the Cosmos chain
2. (cosmos chain) emits an event
3. (wavs) picks up the event
4. (wavs) passes the event data to the component
5. (component) extracts the amount and recipient from the event data
6. (component) encodes the info into an ethereum-friendly type (shared at compiletime w/ alloy sol! macro)
7. (wavs) signs this output from the component, submits it to eigenlayer contract
8. (ethereum: LayerServiceManager) verifies the operator and signature, calls LayerServiceHandler
9. (ethereum: LayerServiceHandler + ERC20) extracts the data, mints tokens
