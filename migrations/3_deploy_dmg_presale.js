require("dotenv").config();
const DemoGreenPresale = artifacts.require("DemoGreenPresale");
const DemoGreen = artifacts.require("DemoGreen");

module.exports = async function (deployer) {
  const demo_green = await DemoGreen.deployed();
  console.log(parseInt(process.env.PRESALE_RATE));
  console.log(process.env.PRESALE_WALLET_ADDRESS);
  console.log(demo_green.address);
  deployer.deploy(
    DemoGreenPresale,
    parseInt(process.env.PRESALE_RATE),
    process.env.PRESALE_WALLET_ADDRESS,
    demo_green.address
  );
};
