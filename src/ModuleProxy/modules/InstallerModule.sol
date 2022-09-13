// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;

import {CreateProxyHelper} from "../lib/CreateProxyHelper.sol";
import {BaseModule} from "./BaseModule.sol";
import {ModuleProxy} from "../ModuleProxy.sol";

contract InstallerModule is CreateProxyHelper, BaseModule {

    constructor(uint256 moduleId_, uint256 version_) 
        BaseModule(moduleId_, version_)
    {}

    event InstallerInstallModule(uint256 newModuleId, address moduleAddr);

    function installModules(address[] memory moduleAddrs) external {
        for (uint256 i = 0; i < moduleAddrs.length; i++) {
            address moduleAddr = moduleAddrs[i];
            uint256 newModuleId = BaseModule(moduleAddr).moduleId();

            moduleLookup[newModuleId] = moduleAddr;
            address proxyAddr = _createProxy(newModuleId);
            trustedSenders[proxyAddr].moduleImpl = moduleAddr;

            emit InstallerInstallModule(
                newModuleId,
                moduleAddr
            );
        }
    }
}
