# Group Currency Token Smart Contract

A group currency would define a number of individual Circles tokens directly or transitively (all accounts trusted by account X) as members. All of those members Circles could be used to mint the group currency.

_Note: The GroupCurrencyToken contract is WIP, non-tested, non-audited and not ready for Mainnet/production usage!_

See https://aboutcircles.com/t/suggestion-for-group-currencies/410 for further details.

## Call Flows for direct minting and delegate minting

### Direct Minting (Token was trusted by `addMember`)

![](https://i.imgur.com/X9YyadU.png)

### Delegate Minting (Token is trusted by `delegateTrust`)

![](https://i.imgur.com/bs1trdg.png)

## Tech Walk-Through

There are two possibilities to explore the functionality of GCT:

1. Examine the unit tests in `test/GroupCurrencyTokenTest`
2. Examine the integration test in `scripts/GroupCurrencyToken.s.sol`

## Prerequisites

* Install Foundry

## Setup

* Clone Repo

## Run (Tests)

* `forge test -vvvv`

## Gnosis Chain Integration Tests

* `forge script script/GroupCurrencyToken.s.sol -vvvv --fork-url=
https://rpc.gnosischain.com`
