require("dotenv").config();
const AirDrop = artifacts.require("AirDrop");

module.exports = function (deployer) {
  deployer.deploy(AirDrop, `${process.env.REWARD_WALLET_ADDRESS}`);
};
