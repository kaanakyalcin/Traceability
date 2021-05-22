const HDWalletProvider = require('truffle-hdwallet-provider');
const fs = require('fs');
module.exports = {
  networks: {
    development: {
      host: "localhost",
      port: 8545,
      network_id: "*",
      gas: 5000000
    },
    abs_msconsortium_mseventadmin_mseventadmin: {
      network_id: "*",
      gasPrice: 0,
      provider: new HDWalletProvider(fs.readFileSync('d:\\Projects\\VSCode\\ProductTraceDemo\\Demo\\memonic2.env', 'utf-8'), "https://mseventadmin.blockchain.azure.com:3200/deM4U1HYptj_x2RgIrEHLBz0")
    }
  },
  compilers: {
    solc: {
      version: "0.8.4",
      settings: {
        optimizer: {
          enabled: true,
          runs: 200
        }
      }
    }
  }
};
