// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./Payment.sol";

error ProjectError();

contract Project is Ownable {
    address public ownerAddress;
    address[] public employeeAddress;
    mapping(address => uint256) public employeeIndex;
    Payment[] public payments;
    address masterPayment;

    constructor(address payable[] memory _employeeAddress) {
        ownerAddress = msg.sender;
        employeeAddress = _employeeAddress;
    }

    receive() external payable {}

    function getOwnerAddress() public view returns (address) {
        return ownerAddress;
    }

    function getEmployeeAddresses() public view returns (address[] memory) {
        return employeeAddress;
    }

    function addEmployee(address payable _employeeAddress) public onlyOwner {
        employeeAddress.push(_employeeAddress);
    }

    //TODO: create method to remove employee based on address not index
    function removeEmployee(uint256 index) public onlyOwner {
        employeeAddress[index] = employeeAddress[employeeAddress.length - 1];

        employeeAddress.pop();
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function getPayments() public view returns (Payment[] memory) {
        return payments;
    }

    function payEmployee(address payable _employeeAddress, uint256 amount) public onlyOwner {
        require(msg.sender == ownerAddress, "Only the owner may pay the employees");
        require(address(this).balance >= amount, "Insuffcient funds to pay employee. Deposit more into the contract.");

        _employeeAddress.transfer(amount);
    }

    function createPayment(address[] memory _payees, uint256[] memory _shares) public onlyOwner {
        Payment payment = new Payment(_payees, _shares);
        payments.push(payment);
    }

    function throwError() external pure {
        revert ProjectError();
    }
}
