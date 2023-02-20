pragma solidity ^0.5.16;

import "../node_modules/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract Withdraw {
    using SafeMath for uint256;

    address private contractOwner;
    mapping(address => uint256) private sales;
    uint256 private enabled = block.timestamp;
    uint256 private counter = 1;

    constructor() public {
        contractOwner = msg.sender;
    }

    // rate limit to not allow calling a function too frequent
    modifier rateLimit(uint256 time) {
        require(block.timestamp >= enabled, "Rate limiting in effect");
        enabled = enabled.add(time);
        _;
    }

    // re-entrancy guard for your function
    modifier entrancyGuard() {
        counter = counter.add(1);
        uint256 guard = counter;
        _;
        require(guard == counter, "That is not allowed");
    }

    function safeWithdraw(uint256 amount)
        external
        rateLimit(30 minutes)
        entrancyGuard
    {
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
