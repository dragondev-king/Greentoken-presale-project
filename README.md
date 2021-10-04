# DemoGreen

Token demo project for R&amp;D firm.

# How to deploy Using Truffle

## Filling .env up

Please signup for infura.io and create an ethereum project. <br />
Copy PROJECT ID from project details page into .env file. <br />
MNEMONIC of .env refers to one of your metamask wallets. <br />
API_KEY of .env refers to API KEY of account signed up in ehterscan.io. <br />
AIRDROP_WALLET_ADDRESS refers to the address of the wallet which is used for Airdrop. <br />
REACT_APP_END_AIRDROP_AT refers to the timestamp of when to end the Airdrop contest. <br />
REACT_APP_CHAIN_ID refers to a hexadecimal number of ethereum network.(0x2A => kovan) <br />
REACT_APP_AIRDROP_ADDRESS refers to the AirDrop contract address. <br />

# How to deploy and verify contracts

open terminal in the root folder of this project. <br />
Then run `truffle migrate --network kovan`. <br />
After that, contract deploys would be being prompted in the terminal. <br />
After deployment completes, you have to verify deployed contracts. <br />
For that, you need the address of contracts and they were shown in the terminal while deploying. <br />
For example, to verify AirDrop contract run `truffle run verify AirDrop@<Address of AirDrop contract> --network kovan`. <br />
This will surely verify contracts. <br />
Then copy build/contracts folder to src folder and change the contracts folder name to abis. <br />
After these, fill REACT_AIPP_AIRDROP_ADDRESS with the AirDrop contract address. <br />
Then run `npm start` and a website will be open in a web browser. <br />
