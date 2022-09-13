// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import {Storage} from "../src/ModuleProxy/Storage.sol";
import {Proxy} from "../src/ModuleProxy/Proxy.sol";
import {ModuleProxy} from "../src/ModuleProxy/ModuleProxy.sol";
import {InstallerModule} from "../src/ModuleProxy/modules/InstallerModule.sol";
import {AddModule} from "../src/ModuleProxy/modules/AddModule.sol";
import {MultiplyModule} from "../src/ModuleProxy/modules/MultiplyModule.sol";

contract DeployModuleProxyScript is Script, Storage {

    Proxy proxy;
    address installerProxy;
    InstallerModule installerModule;
    AddModule addModule;
    MultiplyModule multiplyModule;

    uint256 INIT_VERSION = 100;

    function installModules() internal returns (bool success, bytes memory data) {
        address[] memory addrs = new address[](2);
        addrs[0] = address(addModule);
        addrs[1] = address(multiplyModule);
        (success, data) = address(installerProxy).call(
            abi.encodeWithSignature("installModules(address[])", addrs)
        );
    }

    function setUp() public {
        installerModule = new InstallerModule(MODULEID__INSTALLER, INIT_VERSION);
        proxy = new Proxy(address(installerModule));
        installerProxy = proxy.moduleIdToProxy(MODULEID__INSTALLER);

        addModule = new AddModule(MODULEID__ADD, INIT_VERSION);
        multiplyModule = new MultiplyModule(MODULEID__MULTIPLY, INIT_VERSION);
    }

    function run() public {
        // vm.broadcast();
        (bool success, ) = installModules();
        console2.log("installModules success", success);
        console2.log("Proxy address", address(proxy));
        console2.log("Installer Module Proxy address", installerProxy);
        console2.log("Installer Module Implementation address", address(installerModule));
        console2.log("Add Module Proxy address", proxy.moduleIdToProxy(MODULEID__ADD));
        console2.log("Add Module Implementation address", proxy.moduleIdToImplementation(MODULEID__ADD));
        console2.log("Multiply Module Proxy address", proxy.moduleIdToProxy(MODULEID__MULTIPLY));
        console2.log("Multiply Module Implementation address", proxy.moduleIdToImplementation(MODULEID__MULTIPLY));
    }
}
