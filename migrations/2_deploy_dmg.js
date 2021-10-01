const DemoGreen = artifacts.require("DemoGreen");

module.exports = async function (deployer) {
  await deployer.deploy(DemoGreen);
};
