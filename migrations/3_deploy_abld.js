const ABLD = artifacts.require("AbleDollarToken")

module.exports = async (deployer, network, accounts) => {
    deployer.deploy(ABLD)
      .then(() => console.log("[MIGRATION] [" + parseInt(require("path").basename(__filename)) + "] ABLD deploy: #done"))
}