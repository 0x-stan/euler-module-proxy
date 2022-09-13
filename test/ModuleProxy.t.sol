// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;

import "./utils/TestHelper.sol";
import {Storage} from "../src/ModuleProxy/Storage.sol";
import {Proxy} from "../src/ModuleProxy/Proxy.sol";
import {ModuleProxy} from "../src/ModuleProxy/ModuleProxy.sol";
import {InstallerModule} from "../src/ModuleProxy/modules/InstallerModule.sol";
import {AddModule} from "../src/ModuleProxy/modules/AddModule.sol";
import {MultiplyModule} from "../src/ModuleProxy/modules/MultiplyModule.sol";

contract ModuleProxyTest is TestHelper, Storage {
    Proxy proxy;
    address installerProxy;
    InstallerModule installerModule;
    AddModule addModule;
    MultiplyModule multiplyModule;


    uint256 INIT_VERSION = 100;

    function setUp() public {
        installerModule = new InstallerModule(MODULEID__INSTALLER, INIT_VERSION);
        proxy = new Proxy(address(installerModule));
        installerProxy = proxy.moduleIdToProxy(MODULEID__INSTALLER);

        addModule = new AddModule(MODULEID__ADD, INIT_VERSION);
        multiplyModule = new MultiplyModule(MODULEID__MULTIPLY, INIT_VERSION);
    }

    function installModules() internal returns (bool success, bytes memory data) {
        address[] memory addrs = new address[](2);
        addrs[0] = address(addModule);
        addrs[1] = address(multiplyModule);
        (success, data) = address(installerProxy).call(
            abi.encodeWithSignature("installModules(address[])", addrs)
        );
    }

    function test_installModules() public {
        (bool success, ) = installModules();
        assertTrue(success);

        assertTrue(proxy.moduleIdToImplementation(MODULEID__ADD) == address(addModule));
        assertTrue(proxy.moduleIdToImplementation(MODULEID__MULTIPLY) == address(multiplyModule));
    }

    function test_callMoudle() public {
        installModules();

        address addModuleProxy = proxy.moduleIdToProxy(MODULEID__ADD);
        address multiplyModuleProxy = proxy.moduleIdToProxy(MODULEID__MULTIPLY);

        
        bool success;
        bytes memory data;

        (success, data) = address(addModuleProxy).call(
            abi.encodeWithSignature("moduleVersion()")
        );
        assertTrue(uint256(bytes32(data)) == INIT_VERSION);
        
        (success, data) = address(addModuleProxy).call(
            abi.encodeWithSignature("add(uint256,uint256)", 1, 2)
        );
        assertTrue(uint256(bytes32(data)) == 3);

        (success, data) = address(multiplyModuleProxy).call(
            abi.encodeWithSignature("moduleVersion()")
        );
        assertTrue(uint256(bytes32(data)) == INIT_VERSION);

        (success, data) = address(multiplyModuleProxy).call(
            abi.encodeWithSignature("multiply(uint256,uint256)", 3, 3)
        );
        assertTrue(uint256(bytes32(data)) == 9);
    }

    function test_upgradeModule() public {
        installModules();

        address addModuleProxy = proxy.moduleIdToProxy(MODULEID__ADD);
        address multiplyModuleProxy = proxy.moduleIdToProxy(MODULEID__MULTIPLY);

        // deploy new module, version 200
        addModule = new AddModule(MODULEID__ADD, 200);
        multiplyModule = new MultiplyModule(MODULEID__MULTIPLY, 200);

        installModules();
        
        bool success;
        bytes memory data;

        (success, data) = address(addModuleProxy).call(
            abi.encodeWithSignature("moduleVersion()")
        );
        assertTrue(uint256(bytes32(data)) == 200);

        (success, data) = address(multiplyModuleProxy).call(
            abi.encodeWithSignature("moduleVersion()")
        );
        assertTrue(uint256(bytes32(data)) == 200);
    }

}
