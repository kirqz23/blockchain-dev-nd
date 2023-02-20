pragma solidity ^0.5.16;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Withdraw {
    using SafeMath for uint256;

    address private contractOwner;
    mapping (address => uint256) private sales;

    constructor() public {
        contractOwner = msg.sender;
    }

    function safeWithdraw(uint256 amount) external {
        // Checks
        // check if the sender is externally owned account not contract
        require(msg.sender == tx.origin, "Contracts not allowed");
        require(sales[msg.sender] >= amount, "Insufficient funds");

        // Effects
        uint256 amount = sales[msg.sender];
        sales[msg.sender] = sales[msg.sender].sub(amount);

        // Interaction
        msg.sender.transfer(amount);
    }
}