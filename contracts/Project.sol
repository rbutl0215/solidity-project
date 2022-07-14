// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "hardhat/console.sol";

error ProjectError();

contract Project {
    address public ownerAddress;
    address payable[] public employeeAddress;
    mapping(address => uint256) public employeeBalances;

    constructor(address payable[] memory _employeeAddress) {
        ownerAddress = msg.sender;
        employeeAddress = _employeeAddress;
    }

    receive() external payable {}

    function getOwnerAddress() public view returns (address) {
        return ownerAddress;
    }

    function getEmployeeAddresses() public view returns (address payable[] memory) {
        return employeeAddress;
    }

    function addEmployee(address payable _employeeAddress) public {
        employeeAddress.push(_employeeAddress);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function payEmployee(address payable _employeeAddress, uint256 amount) public {
        require(msg.sender == ownerAddress, "Only the owner may pay the employees");
        require(address(this).balance >= amount, "Insuffcient funds to pay employee. Deposit more into the contract.");

        _employeeAddress.transfer(amount);
    }

    //Below are preliminary functions for allow an employee to accrue accounts receviable without transfering funds
    function payEmployeeFullBalance(address payable _employeeAddress) public {
        require(msg.sender == ownerAddress);
        require(address(this).balance > employeeBalances[_employeeAddress]);

        _employeeAddress.transfer(employeeBalances[_employeeAddress]);

        employeeBalances[_employeeAddress] = 0;
    }

    function increaseEmployeeBalance(address _employeeAddress, uint256 _payment) public {
        employeeBalances[_employeeAddress] += _payment;
    }

    function throwError() external pure {
        revert ProjectError();
    }
}
