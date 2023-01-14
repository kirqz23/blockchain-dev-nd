var Web3 = require('web3');

var url = 'https://mainnet.infura.io/v3/bcab84a563b142a786522267f8306916';

var web3 = new Web3(url);

var address = '0x8E21D1CE02fD6Cec455Da473b9D969424bAa9678';

web3.eth.getBalance(address, (err, bal) => { balance = bal });
