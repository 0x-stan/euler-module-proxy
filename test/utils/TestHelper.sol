// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

contract TestHelper is Test {
    address owner = 0xb4c79daB8f259C7Aee6E5b2Aa729821864227e84;
    uint256 alicePrivateKey = 0xA11CE;
    uint256 bobPrivateKey = 0xB0B;

    address alice = vm.addr(alicePrivateKey);
    address bob = vm.addr(bobPrivateKey);
}
