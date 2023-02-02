pragma solidity ^0.4.24;

contract LemonadeStand {
    
    address owner;
    uint skuCount;

    enum State { ForSale, Sold, Shipped }

    struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address seller;
        address buyer;
    }

    mapping (uint -> Item) items;

    event ForSale(uint skuCount);
    event Sold(uint sku);
    event Shipped(uint sku);

    modifier onlyOnwer(){
        require(msg.sender == owner);
        _;
    }

    modifier verifyCaller(address _address) {
        require(msg.sender == _address);
        _;
    }

    modifier paidEnough(uint _price) {
        require(msg.value >= _price);
        _;
    }

    modifier forSale(uint _sku) {
        require(items[_sku].state == State.ForSale);
        _;
    }

    modifier sold (uint _sku) {
        require(items[_sku].state == State.Sold);
        _;
    }

    modifier makeRefund(uint _sku) {
        _;
        price = items[_sku].price;
        if (msg.value - price > 0) {
            items[sku].buyer.transfer(msg.value - price);
        }
    }

    constructor() public {
        owner = msg.sender;
        skuCount = 0;
    }

    function addItem(string _name, uint _price) onlyOnwer public {
        skuCount = skuCount + 1;
        emit ForSale(skuCount);
        items[skuCount] = Item({
            name: _name,
            sku: skuCount,
            price: _price,
            state: State.ForSale,
            seller: msg.sender,
            buyer: 0
        });
    }

    function buyItem(uint sku) forSale(sku) paidEnough(items[sku].price) makeRefund(sku) public payable {
        address buyer = msg.sender;
        uint price = items[sku].price;
        items[sku].buyer = buyer;
        items[sku].state = State.Sold;
        items[sku].seller.transfer(price);
        emit Sold(sku);
    }

    function fetchItem(uint _sku) public view returns (string name, uint sku, uint price, string stateIs, address seller, address buyer) {
        uint state;
        name = items[_sku].name;
        sku = items[_sku].sku;
        price = items[_sku].price;
        state = uint(items[_sku].state);
        if (state == 0){
            stateIs = "For Sale";
        }
        if (state == 1){
            stateIs = "Sold";
        }
        seller = items[_sku].seller;
        buyer = items[_sku].buyer;
    }

    function shipItem(uint _sku) sold(_sku) verifyCaller(items[_sku].seller) public {
        items[_sku].state = State.Shipped;
        emit Shipped(_sku);
    }
}
