const ABLX = artifacts.require("AbleToken")

module.exports = async (deployer, network, accounts) => {
    deployer.deploy(ABLX)
      .then(() => console.log("[MIGRATION] [" + parseInt(require("path").basename(__filename)) + "] ABLX deploy: #done"))
}