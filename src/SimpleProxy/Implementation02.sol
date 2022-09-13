// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;

import {Storage} from "./Storage.sol";

contract Implementation02 is Storage {
    constructor() {}

    function getVersion() external pure returns(uint256) {
        return 200;
    }

}
