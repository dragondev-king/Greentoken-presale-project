require("dotenv").config();
const AirDrop = artifacts.require("AirDrop");

module.exports = function (deployer) {
  deployer.deploy(
    AirDrop,
    `${process.env.PRESALE_WALLET_ADDRESS}`,
    parseInt(process.env.END_AIRDROP_AT)
  );
};
