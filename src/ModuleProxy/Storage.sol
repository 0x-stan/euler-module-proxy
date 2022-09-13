// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;

abstract contract Storage {
    // Public single-proxy modules
    uint256 internal constant MODULEID__INSTALLER = 1;
    uint256 internal constant MODULEID__ADD = 2;
    uint256 internal constant MODULEID__MULTIPLY = 3;

    address creator;
    address implementation;
    uint256 version;

    mapping(uint256 => address) moduleLookup; // moduleId => module implementation
    mapping(uint256 => address) proxyLookup; // moduleId => proxy address (only for single-proxy modules)

    struct TrustedSenderInfo {
        uint32 moduleId; // 0 = un-trusted
        address moduleImpl; // only non-zero for external single-proxy modules
    }

    mapping(address => TrustedSenderInfo) trustedSenders; // sender address => moduleId (0 = un-trusted)
}
