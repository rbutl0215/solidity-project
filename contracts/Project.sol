// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/finance/VestingWallet.sol";
import "./Payment.sol";

error ProjectError();

contract Project is Ownable {
    address public ownerAddress;
    address[] public employeeAddresses;
    mapping(address => uint256) public employeeIndex;
    Payment[] public payments;
    address[] public paymentClones;
    address masterPayment;

    constructor(address payable[] memory _employeeAddresses) {
        ownerAddress = msg.sender;
        employeeAddresses = _employeeAddresses;

        //WIP: Utilize clone factory framework to minimize gas fees
        // address[] memory initializePayees;
        // uint[] memory initializeShares;

        // Payment _masterPayment = new Payment(initializePayees, initializeShares);
        // masterPayment = address(_masterPayment);
    }

    receive() external payable {}

    function getOwnerAddress() public view returns (address) {
        return ownerAddress;
    }

    function getEmployeeAddresses() public view returns (address[] memory) {
        return employeeAddresses;
    }

    function addEmployee(address payable _employeeAddress) public onlyOwner {
        employeeAddresses.push(_employeeAddress);
    }

    //TODO: create method to remove employee based on address not index
    function removeEmployee(uint256 index) public onlyOwner {
        employeeAddresses[index] = employeeAddresses[employeeAddresses.length - 1];

        employeeAddresses.pop();
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getPayments() public view returns (Payment[] memory) {
        return payments;
    }

    //Leaving this in for now, but likely will be moved to Payment contract
    function payEmployee(address payable _employeeAddress, uint256 amount) public onlyOwner {
        require(msg.sender == ownerAddress, "Only the owner may pay the employees");
        require(address(this).balance >= amount, "Insuffcient funds to pay employee. Deposit more into the contract.");

        _employeeAddress.transfer(amount);
    }

    function createPayment(
        address[] memory _payees,
        uint256[] memory _shares,
        uint64 amount
    ) public onlyOwner returns (address) {
        Payment payment = new Payment(_payees, _shares);
        payments.push(payment);

        payable(payment).transfer(amount);
        return address(payment);
    }

    function createAutomatedPaymentSchedule(
        address[] memory _payees,
        uint256[] memory _shares,
        uint64 startTime,
        uint64 vestingDuration,
        uint64 amount
    ) public onlyOwner {
        //Initialize Payment Contact with No ETH
        address paymentAddress = createPayment(_payees, _shares, 0);

        VestingWallet vestingWallet = new VestingWallet(paymentAddress, startTime, vestingDuration);

        payable(vestingWallet).transfer(amount);
    }

    //WIP: Utilize clone factory framework to minimize gas fees
    // function createPaymentClone(address[] memory _payees, uint256[] memory _shares) public onlyOwner {
    //     address clonePayment = Clones.clone(masterPayment);
    //     paymentClones.push(clonePayment);
    // }

    function throwError() external pure {
        revert ProjectError();
    }
}
