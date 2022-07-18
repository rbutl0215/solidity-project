// SPDX-License-Identifier: MIT
pragma solidity >=0.8.4;

import "hardhat/console.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

error PaymentError();

contract Payment is PaymentSplitter {
    constructor(address[] memory _payees, uint256[] memory _shares) payable PaymentSplitter(_payees, _shares) {}

    function throwError() external pure {
        revert PaymentError();
    }
}
