require("dotenv").config();
const DemoGreenPresale = artifacts.require("DemoGreenPresale");
const DemoGreen = artifacts.require("DemoGreen");

module.exports = async function (deployer) {
  const demo_green = await DemoGreen.deployed();
  deployer.deploy(
    DemoGreenPresale,
    parseInt(process.env.PRESALE_RATE),
    process.env.PRESALE_WALLET_ADDRESS,
    demo_green.address
  );
};
