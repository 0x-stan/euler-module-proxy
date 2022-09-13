// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;

import {CreateProxyHelper} from "./lib/CreateProxyHelper.sol";

contract Proxy is CreateProxyHelper {
    constructor(address installerModule) {
        moduleLookup[MODULEID__INSTALLER] = installerModule;
        address installerProxy = _createProxy(MODULEID__INSTALLER);
        trustedSenders[installerProxy].moduleImpl = installerModule;
    }

    function moduleIdToImplementation(uint moduleId) external view returns (address) {
        return moduleLookup[moduleId];
    }

    function moduleIdToProxy(uint moduleId) external view returns (address) {
        return proxyLookup[moduleId];
    }

    function dispatch() external {
        uint256 moduleId = trustedSenders[msg.sender].moduleId;
        address moduleImpl = trustedSenders[msg.sender].moduleImpl;

        require(moduleId != 0, "Proxy:sender-not-trusted");
        if (moduleImpl == address(0)) moduleImpl = moduleLookup[moduleId];

        uint256 msgDataLength = msg.data.length;
        // 4: dispatch selector
        // 4: delegatecall selector
        // 20: caller address
        require(msgDataLength >= (4 + 4 + 20), "Proxy:input-too-short");

        assembly {
            let payloadSize := sub(calldatasize(), 4)
            calldatacopy(0, 4, payloadSize) // remove dispatch selector
            mstore(payloadSize, shl(96, caller())) // add caller address to tail
            
            // insize = payloadSize + 20(calleraddress)
            let result := delegatecall(gas(), moduleImpl, 0, add(payloadSize, 20), 0, 0)

            returndatacopy(0, 0, returndatasize())
            switch result 
                case 0 { revert(0, returndatasize()) }
                default { return(0, returndatasize()) }
        }

    }

}