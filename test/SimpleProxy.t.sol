// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;

import "./utils/TestHelper.sol";
import {SimpleProxy} from "src/SimpleProxy/SimpleProxy.sol";
import {Implementation01} from "src/SimpleProxy/Implementation01.sol";
import {Implementation02} from "src/SimpleProxy/Implementation02.sol";

contract SimpleProxyTest is TestHelper {
    SimpleProxy proxy;
    Implementation01 impl01;
    Implementation02 impl02;

    function setUp() public {
        proxy = new SimpleProxy();
        impl01 = new Implementation01();
        impl02 = new Implementation02();
        proxy.upgrade(address(impl01));
    }

    function test_upgrade() public {

        vm.prank(alice);
        bytes memory data;
        (, data) = address(proxy).call(
            abi.encodeWithSignature("getVersion()")
        );
        assertTrue(uint256(bytes32(data)) == 100);

        proxy.upgrade(address(impl02));

        vm.prank(alice);
        (, data) = address(proxy).call(
            abi.encodeWithSignature("getVersion()")
        );
        assertTrue(uint256(bytes32(data)) == 200);

    }
}
