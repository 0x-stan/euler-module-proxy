// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;

import {Storage} from "./Storage.sol";

contract SimpleProxy is Storage {
    constructor() {
        creator = msg.sender;
    }

    function _fallback() internal {
        require(msg.sender != creator);
        // payable(implementation).delegatecall(msg.data);
        _delegatecall(implementation);
    }

    fallback() external {
        _fallback();
    }

    receive() external payable {
        _fallback();
    }


    function _delegatecall(address implementation_) internal {
        assembly {
            // Copy msg.data. We take full control of memory in this inline assembly
            // block because it will not return to Solidity code. We overwrite the
            // Solidity scratch pad at memory position 0.
            calldatacopy(0, 0, calldatasize())

            // Call the implementation.
            // out and outsize are 0 because we don't know the size yet.
            let result := delegatecall(gas(), implementation_, 0, calldatasize(), 0, 0)

            // Copy the returned data.
            returndatacopy(0, 0, returndatasize())

            switch result
            // delegatecall returns 0 on error.
            case 0 {
                revert(0, returndatasize())
            }
            default {
                return(0, returndatasize())
            }
        }
    }

    function upgrade(address newImplementation) external {
        if (msg.sender != creator) _fallback();
        implementation = newImplementation;
    }
}
