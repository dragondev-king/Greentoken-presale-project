# DemoGreen

Token demo project for R&amp;D firm.

# How to deploy Using Truffle

## Filling .env up

Please signup for infura.io and create an ethereum project.
Copy PROJECT ID from project details page into .env file.
MNEMONIC of .env refers to one of your metamask wallets.
API_KEY of .env refers to API KEY of account signed up in ehterscan.io.
AIRDROP_WALLET_ADDRESS refers to the address of the wallet which is used for Airdrop.
REACT_APP_END_AIRDROP_AT refers to the timestamp of when to end the Airdrop contest.
REACT_APP_CHAIN_ID refers to a hexadecimal number of ethereum network.(0x2A => kovan)
REACT_APP_AIRDROP_ADDRESS refers to the AirDrop contract address.

# How to deploy and verify contracts

open terminal in the root folder of this project.
Then run `truffle migrate --network kovan`.
After that, contract deploys would be being prompted in the terminal.
After deployment completes, you have to verify deployed contracts.
For that, you need the address of contracts and they were shown in the terminal while deploying.
For example, to verify AirDrop contract run `truffle run verify AirDrop@<Address of AirDrop contract> --network kovan`.
This will surely verify contracts.
Then copy build/contracts folder to src folder and change the contracts folder name to abis.
After these, fill REACT_AIPP_AIRDROP_ADDRESS with the AirDrop contract address.
Then run `npm start` and a website will be open in a web browser.
