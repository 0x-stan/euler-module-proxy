// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;

import {Storage} from "../Storage.sol";

contract BaseModule is Storage {
    uint256 public immutable moduleId;
    uint256 public immutable moduleVersion;

    constructor(uint256 moduleId_, uint256 version_) {
        moduleId = moduleId_;
        moduleVersion = version_;
    }

    function unpackTrailingParams() public pure returns (address msgSender, address proxyAddr) {
        assembly {
            msgSender := shr(96, calldataload(sub(calldatasize(), 40)))
            proxyAddr := shr(96, calldataload(sub(calldatasize(), 20)))
        }
    }
    
}
