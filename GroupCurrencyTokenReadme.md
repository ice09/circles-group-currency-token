# Group Currency Token Smart Contract

A group currency would define a number of individual Circles tokens directly or transitively (all accounts trusted by account X) as members. All of those members Circles could be used to mint the group currency.

_Note: The GroupCurrencyToken contract is WIP, non-tested, non-audited and not ready for Mainnet/production usage!_

See https://aboutcircles.com/t/suggestion-for-group-currencies/410 for further details.

## Call Flows for mint and mintDelegate

### mint

![flow](https://drive.google.com/uc?export=view&id=1SJx0rxnHJnMONTHY59n1vRUNkhSqEe1M)

### memberMint

![flow](https://drive.google.com/uc?export=view&id=1QIYX3UM2HqW8UJGaUIH13SnADnZadb73)

### delegateMint

![flow](https://drive.google.com/uc?export=view&id=1t2mFhNWxrtlSSyn5TbGAh6-Nz4ds1AkA)

## Tech Walk-Through

### Ganache

The initial drafts uses manual steps to setup, deploy and test the `GroupCurrencyToken` smart contract.

* Clone circles-contract-group-currency fork: `git clone git@github.com:ice09/circles-contracts.git`
* Switch to branch `hub-v1-comp`
* Open contracts in Remix-IDE at https://remix.ethereum.org/ with *remixd*: `remixd -s $(pwd) -u https://remix.ethereum.org`
* Start Ganache with mnemonic `test test test test test test test test test test test junk`
* Deploy `Hub.sol` with params `"1","1","CRC","Circles","50000000000000000000","1","1"` in Environment *Ganache Provider* -> **0x5FbDB2315678afecb367f032d93F642f64180aa3**
* Deploy `GroupCurrencyTokenFactory.sol` and call `createGroupCurrencyToken` OR
* Deploy `GroupCurrencyToken.sol` with params 
`"0x5FbDB2315678afecb367f032d93F642f64180aa3","0x0000000000000000000000000000000000000001", "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266", 1, "GCT", "GCT"` -> **0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512**
  * This will also call `organizationSignup` on Hub.
* Call `signup` on Hub contract with Ganache Account 1 `0x70997970C51812dc3A010C7d01b50e0d17dc79C8` (Alice Signup)
	* This will deploy an individual Circles-Token from the Hub contract with Token address **0xa16E02E87b7454126E5E10d957A927A7F5B5d2be**
* Call `addMemberToken` on GCT at **0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512** with parameter `0xa16E02E87b7454126E5E10d957A927A7F5B5d2be`
* Load `Token.sol` at `0xa16E02E87b7454126E5E10d957A927A7F5B5d2be`
	* This is the Circles-Token which will be used as Collateral Token
* Transfer with Ganache Account 1 "1000" Tokens to GCT Address `0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512`

#### mint

* [GroupCurrencyToken] `mint(0xa16E02E87b7454126E5E10d957A927A7F5B5d2be,1000)` with any Remix Account (**Note: unrestricted access! Anybody can mint!**)

### Remix VM (London)

The initial drafts uses manual steps to setup, deploy and test the `GroupCurrencyToken` smart contract.

* Clone circles-contract-group-currency fork: `git clone git@github.com:ice09/circles-contracts.git`
* Switch to branch `hub-v1-comp`
* Open contracts in Remix-IDE at https://remix.ethereum.org/ with *remixd*: `remixd -s $(pwd) -u https://remix.ethereum.org`
* Deploy `Hub.sol` with params `"1","1","CRC","Circles","50000000000000000000","1","1"` in Environment *JavaScript VM (London)*
* Deploy `GroupCurrencyTokenFactory.sol` and call `createGroupCurrencyToken` OR
* Deploy `GroupCurrencyToken.sol` with params `"0xd9145CCE52D386f254917e481eB44e9943F39138","0x0000000000000000000000000000000000000001", "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", 1, "GCT", "GCT"`
  * This will also call `organizationSignup` on Hub.
* Call `signup` on Hub contract with Remix Account 1 `0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2` (Alice Signup)
	* This will deploy an individual Circles-Token from the Hub contract with Token address `0x5C9eb5D6a6C2c1B3EFc52255C0b356f116f6f66D`
* Call `addMemberToken` at `...` with parameter `...` (TODO: lookup addresses for GCT and Token)
* Load `Token.sol` at `0x5C9eb5D6a6C2c1B3EFc52255C0b356f116f6f66D`
	* This is the Circles-Token which will be used as Collateral Token
* Transfer with Remix Account 1 "1000" Tokens to GCT Address `0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8`

#### mint

* [GroupCurrencyToken] `mint(0x5C9eb5D6a6C2c1B3EFc52255C0b356f116f6f66D,1000)` with any Remix Account (**Note: unrestricted access! Anybody can mint!**)

#### memberMint

* [CollateralToken] `approve` GroupCurrencyToken address (eg. amount 10000000000000000000)
* [GroupCurrencyToken] `addMember` for Collateral Token address
* [GroupCurrencyToken] `mint` 10000000000000000000 for Collateral token

#### delegateMint

* [CollateralToken] `approve` GroupCurrencyToken address (eg. amount 10000000000000000000)
* [Hub] `signup` with second account
* [Hub] `trust` with second account: firstAccountAddress, 100
* [GroupCurrencyToken] `addDelegateTrustee` with first account: secondAccountAddress
* [GroupCurrencyToken] `mintDelegate` with first account: secondAccountAddress, CollateralToken, 10000