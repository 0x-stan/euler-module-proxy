// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;

import {Storage} from "../Storage.sol";
import {ModuleProxy} from "../ModuleProxy.sol";

abstract contract CreateProxyHelper is Storage {

    event ProxyCreated(uint256 newModuleId, address moduleAddr);

    function _createProxy(uint256 proxyModuleId) internal returns(address proxyAddr) {
        require(proxyModuleId != 0, "InstallerModule:invalid-module");

        // If we've already created a proxy for a single-proxy module, just return it:

        if (proxyLookup[proxyModuleId] != address(0)) return proxyLookup[proxyModuleId];

        proxyAddr = address(new ModuleProxy());
        proxyLookup[proxyModuleId] = proxyAddr;

        trustedSenders[proxyAddr] = TrustedSenderInfo({ moduleId: uint32(proxyModuleId), moduleImpl: address(0) });

        emit ProxyCreated(proxyModuleId, proxyAddr);
    }

}
