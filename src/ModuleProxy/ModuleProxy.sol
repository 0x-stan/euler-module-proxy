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
            // emit by ModuleProxy
            assembly {
                mstore(0, 0)
                calldatacopy(31, 0, calldatasize())

                switch mload(0) // numTopics
                    case 0 { log0(32,  sub(calldatasize(), 1)) }
                    case 1 { log1(64,  sub(calldatasize(), 33),  mload(32)) }
                    case 2 { log2(96,  sub(calldatasize(), 65),  mload(32), mload(64)) }
                    case 3 { log3(128, sub(calldatasize(), 97),  mload(32), mload(64), mload(96)) }
                    case 4 { log4(160, sub(calldatasize(), 129), mload(32), mload(64), mload(96), mload(128)) }
                    default { revert(0, 0) }

                return(0, 0)
            }
        } else {
            assembly {
                // dispatch() selector
                mstore(0, 0xe9c4a3ac00000000000000000000000000000000000000000000000000000000)
                // dispatch selector + calldata
                calldatacopy(4, 0, calldatasize())
                // dispatch selector + calldata + caller address
                mstore(add(4, calldatasize()), shl(96, caller()))

                // 24 = 4 dispatch selector + 20 caller address
                // insize = calldatasize + 24
                // NOTICE: call
                let result := call(gas(), creator_, 0, 0, add(24, calldatasize()), 0, 0)

                returndatacopy(0, 0, returndatasize())
                switch result
                    case 0 { revert(0, returndatasize()) }
                    default { return(0, returndatasize()) }
            }
        }
    }
}
