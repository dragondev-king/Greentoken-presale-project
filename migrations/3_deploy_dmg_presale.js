require("dotenv").config();
const Public_PreSale = artifacts.require("Public_PreSale");
const DemoGreen = artifacts.require("DemoGreen");

module.exports = function (deployer) {
  const demo_green = DemoGreen.deployed();
  deployer.deploy(
    Public_PreSale,
    parseInt(process.env.PRESALE_RATE),
    process.env.PRESALE_WALLET_ADDRESS,
    demo_green.address
  );
};
