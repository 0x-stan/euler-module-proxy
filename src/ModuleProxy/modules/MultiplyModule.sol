// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.13;

import {BaseModule} from "./BaseModule.sol";

contract MultiplyModule is BaseModule {
    constructor(uint256 moduleId_, uint256 version_)
        BaseModule(moduleId_, version_)
    {}

    function multiply(uint256 x, uint256 y) external pure returns(uint256) {
        return x * y;
    }
    
}
