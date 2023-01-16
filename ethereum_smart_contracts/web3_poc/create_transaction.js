/*##########################

CONFIGURATION
##########################*/

// -- Step 1: Set up the appropriate configuration 
const Web3 = require("web3");
const EthereumTransaction = require("ethereumjs-tx");
const web3 = new Web3('HTTP://127.0.0.1:7545');

// -- Step 2: Set the sending and receiving addresses for the transaction. 
var sendingAddress = '0x8ff067800fD2Dc242f1FE9c7D8A6BD781e9f12Ad';
var receivingAddress = '0xD1034309A2bd75DD76C86eC917e11946F065813A';

// -- Step 3: Check the balances of each address 
web3.eth.getBalance(sendingAddress).then(console.log);
web3.eth.getBalance(receivingAddress).then(console.log);

/*##########################

CREATE A TRANSACTION
##########################*/

// -- Step 4: Set up the transaction using the transaction variables as shown 
var rawTransaction = { nonce: "0x2", to: receivingAddress, gasPrice: '0x20000000', gasLimit: '0x30000', value: '0x100', data: "0x0" }

// -- Step 5: View the raw transaction rawTransaction

// -- Step 6: Check the new account balances (they should be the same) 
web3.eth.getBalance(sendingAddress).then(console.log);
web3.eth.getBalance(receivingAddress).then(console.log);

// Note: They haven't changed because they need to be signed...

/*##########################

Sign the Transaction
##########################*/

// -- Step 7: Sign the transaction with the Hex value of the private key of the sender 
var privateKeySender = '73c1aaee3c2e3ed4db2579b8422baed085d60e64d8b349d1f5759f8ef4df75ae';
var privateKeySenderHex = new Buffer.from(privateKeySender, 'hex');
var transaction = new EthereumTransaction.Transaction(rawTransaction);
transaction.sign(privateKeySenderHex);

/*#########################################

Send the transaction to the network
#########################################*/

// -- Step 8: Send the serialized signed transaction to the Ethereum network. 
var serializedTransaction = transaction.serialize();
web3.eth.sendSignedTransaction(serializedTransaction);
