
const fs = require('fs');
const HDWallet = require('./node_modules/truffle-hdwallet-provider');
const infuraKey = fs.readFileSync("infura.secret").toString().trim();
const mnemonic = fs.readFileSync("mnemonic.secret").toString().trim();


module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 7545,
      network_id: "*" // Match any network id
    },
    goerli: {
      provider: () => new HDWallet(mnemonic, `https://goerli.infura.io/v3/${infuraKey}`),
      network_id: 5,
      gas: 10000000,
      gasPrice: 80000000000,
    },

  }
};