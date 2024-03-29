// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "../node_modules/@openzeppelin/contracts/utils/math/SafeMath.sol";

contract FlightSuretyData {
    using SafeMath for uint256;

    /********************************************************************************************/
    /*                                       DATA VARIABLES                                     */
    /********************************************************************************************/

    address private contractOwner; // Account used to deploy contract
    bool private operational; // Blocks all state changes throughout the contract if false
    uint256 private insuranceFund; // Amount of fund for insurance
    mapping(address => bool) private authorizedCallers;

    struct Airline {
        bool isRegistered;
        bool isFunded;
    }

    mapping(address => Airline) private airlines;
    uint256 private numAirlinesRegistered;
    uint256 private numAirlinesFunded;

    struct Flight {
        bool isRegistered;
        uint8 statusCode;
        uint256 updatedTimestamp;
        address airline;
    }
    mapping(bytes32 => Flight) private flights;

    mapping(bytes32 => uint256) private insurances;

    /********************************************************************************************/
    /*                                       EVENT DEFINITIONS                                  */
    /********************************************************************************************/

    /**
     * @dev Constructor
     *      The deploying account becomes contractOwner
     */
    constructor() {
        contractOwner = msg.sender;
        operational = true;
    }

    /********************************************************************************************/
    /*                                       FUNCTION MODIFIERS                                 */
    /********************************************************************************************/

    // Modifiers help avoid duplication of code. They are typically used to validate something
    // before a function is allowed to be executed.

    /**
     * @dev Modifier that requires the "operational" boolean variable to be "true"
     *      This is used on all state changing functions to pause the contract in
     *      the event there is an issue that needs to be fixed
     */
    modifier requireIsOperational() {
        require(operational, "Contract is currently not operational");
        _; // All modifiers require an "_" which indicates where the function body will be added
    }

    /**
     * @dev Modifier that requires the "ContractOwner" account to be the function caller
     */
    modifier requireContractOwner() {
        require(msg.sender == contractOwner, "Caller is not contract owner");
        _;
    }

    modifier requireAuthCaller() {
        require(authorizedCallers[msg.sender], "Caller is not authorized");
        _;
    }

    /********************************************************************************************/
    /*                                       UTILITY FUNCTIONS                                  */
    /********************************************************************************************/

    /**
     * @dev Get operating status of contract
     *
     * @return A bool that is the current operating status
     */
    function isOperational() public view requireAuthCaller returns (bool) {
        return operational;
    }

    /**
     * @dev Sets contract operations on/off
     *
     * When operational mode is disabled, all write transactions except for this one will fail
     */
    function setOperatingStatus(bool _mode) external requireContractOwner {
        operational = _mode;
    }

    function authorizeCaller(
        address _authAddress
    ) external requireContractOwner {
        authorizedCallers[_authAddress] = true;
    }

    function deauthorizeCaller(
        address _authAddress
    ) external requireContractOwner {
        delete authorizedCallers[_authAddress];
    }

    function isAirline(
        address _airline
    ) external view requireIsOperational requireAuthCaller returns (bool) {
        return airlines[_airline].isRegistered;
    }

    function isAirlineFunded(
        address _airline
    ) external view requireIsOperational requireAuthCaller returns (bool) {
        return airlines[_airline].isFunded;
    }

    function getAirlinesRegistered()
        external
        view
        requireAuthCaller
        returns (uint256)
    {
        return numAirlinesRegistered;
    }

    function getAirlinesFunded()
        external
        view
        requireAuthCaller
        returns (uint256)
    {
        return numAirlinesFunded;
    }

    function getFlightAirline(bytes32 _name) external view returns (address) {
        return flights[_name].airline;
    }

    /********************************************************************************************/
    /*                                     SMART CONTRACT FUNCTIONS                             */
    /********************************************************************************************/

    /**
     * @dev Add an airline to the registration queue
     *      Can only be called from FlightSuretyApp contract
     *
     */
    function registerAirline(
        address _newAirline
    ) external requireIsOperational requireAuthCaller {
        require(
            !airlines[_newAirline].isRegistered,
            "Airline is already registered"
        );

        airlines[_newAirline] = Airline({isRegistered: true, isFunded: false});
        numAirlinesRegistered.add(1);
    }

    function registerFlight(
        bytes32 _name,
        address _airlineAddress,
        uint8 _status
    ) external requireIsOperational requireAuthCaller {
        require(!flights[_name].isRegistered, "Flight was already registered");
        flights[_name] = Flight({
            isRegistered: true,
            statusCode: _status,
            updatedTimestamp: block.timestamp,
            airline: _airlineAddress
        });
    }

    function updateFlightStatus(
        bytes32 _name,
        uint8 _status,
        uint256 timestamp
    ) external requireIsOperational requireAuthCaller {
        require(!flights[_name].isRegistered, "Flight was already registered");
        flights[_name].statusCode = _status;
        flights[_name].updatedTimestamp = timestamp;
    }

    /**
     * @dev Buy insurance for a flight
     *
     */
    function buy(
        address _passanger,
        address _airline,
        bytes32 _flight
    ) external payable requireIsOperational requireAuthCaller {
        bytes32 insurance = keccak256(
            abi.encodePacked(_passanger, _airline, _flight, block.timestamp)
        );
        insurances[insurance] = msg.value;
    }

    /**
     *  @dev Credits payouts to insurees
     */
    function creditInsurees() external pure {}

    /**
     *  @dev Transfers eligible payout funds to insuree
     *
     */
    function pay() external pure {}

    /**
     * @dev Initial funding for the insurance. Unless there are too many delayed flights
     *      resulting in insurance payouts, the contract should be self-sustaining
     *
     */
    function fund(
        address _airline
    ) public payable requireIsOperational requireAuthCaller {
        insuranceFund.add(msg.value);
        airlines[_airline].isFunded = true;
        numAirlinesFunded.add(1);
    }

    function getFlightKey(
        address airline,
        string memory flight,
        uint256 timestamp
    ) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(airline, flight, timestamp));
    }

    /**
     * @dev Fallback function for funding smart contract.
     *
     */
    fallback() external payable {
        fund(tx.origin);
    }

    receive() external payable {
        fund(tx.origin);
    }
}
