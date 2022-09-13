// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;

contract ModuleProxy {

    address creator;

    constructor() {
        creator = msg.sender;
    }

    fallback() external {
        address creator_ = creator;

        if (msg.sender == creator_) {
            // emit by proxy
        } else {
            assembly {
                mstore(0, 0xe9c4a3ac00000000000000000000000000000000000000000000000000000000) // dispatch() selector
                // dispatch selector + calldata
                calldatacopy(4, 0, calldatasize())
                // dispatch selector + calldata + caller address
                mstore(add(4, calldatasize()), shl(96, caller()))

                // 24 = 4 dispatch selector + 20 caller address
                // insize = calldatasize + 24
                let result := call(gas(), creator_, 0, 0, add(24, calldatasize()), 0, 0)

                returndatacopy(0, 0, returndatasize())
                switch result
                    case 0 { revert(0, returndatasize()) }
                    default { return(0, returndatasize()) }
            }
        }
    }
}
