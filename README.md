# Euler Module Proxy

A simply exmaple to learn Euler's upgradable module proxy.

## Quick Start

install

```bash
forge install
```

test

```bash
forge test
```

run script

```bash
# deploy contracts
forge script script/DeployModuleProxyScript.s.sol
```

## Simple Proxy

Proxy -> Implementation

Single Proxy and Implementation contract.

## Module Proxy

```bash
MainProxy
├── InstallerModule
│   ├── InstallerModuleProxy
│   └── InstallerModuleImplementation
├── AddModule
│   ├── AddModuleProxy
│   └── AddModuleImplementation
└── MultiplyModule
    ├── MultiplyModuleProxy
    └── MultiplyModuleImplementation
```

MainProxy is the main entry, each module has a ModuleProxy contract and a ModuleImplementation contract.

### deploy process

1. deploy InstallerModuleImplementation
2. deploy MainProxy with InstallerModuleImplementation address
3. deploy AddModuleImplementation and MultiplyModuleImplementation
4. call InstallerModuleProxy installModules function to install add and multiply modules. It will deploy a ModuleProxy for each module, and mapping ModuleImplementation to ModuleProxy

When call function on ModuleProxy, ModuleProxy will call main Proxy's dispatch function, and dispatch will delegatecall ModuleImplementation's logic function.

Notice: MainProxy use call assembly code, and ModuleProxy use delegatecall assembly code.

```solidity
// src/ModuleProxy/Proxy.sol
function dispatch() external {
    ...

    assembly {
        ...
        // insize = payloadSize + 20(calleraddress)
        let result := delegatecall(gas(), moduleImpl, 0, add(payloadSize, 20), 0, 0)
        ...
    }

}

// src/ModuleProxy/ModuleProxy.sol
fallback() external {
    ...

    assembly {
        ...
        // 24 = 4 dispatch selector + 20 caller address
        // insize = calldatasize + 24
        let result := call(gas(), creator_, 0, 0, add(24, calldatasize()), 0, 0)
        ...
    }

}

```

## Flow

![Euler-Module-Proxy-Flow](./img/Euler-Module-Proxy%402x.png)
