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

## Dive Into Euler's ModuleProxy

传统的 Proxy 模式是没有模块化的，Euler 对其进行改进，使得不同模块可以单独升级。整体的架构是一个主入口代理合约 MainProxy，一个 Installer 模块，以及其他的功能模块，其中每个模块都有一个 Implementation 合约(执行逻辑)和一个 ModuleProxy 合约(代理)

![](https://github.com/0x-stan/euler-module-proxy/blob/main/img/Euler-module-proxy-01.png)

### 合约的部署流程

1. 部署 Installer 模块的 Implementation(执行逻辑合约)
2. 传入 1 的地址作为入参，部署 MainProxy 主入口合约
3. MainProxy 造函数会通过 ModuleProxy 模板创建一个 Installer 模块的 Proxy 合约，并将两者地址绑定(mapping)

![](https://github.com/0x-stan/euler-module-proxy/blob/main/img/Euler-module-proxy-02.png)

### 功能模块安装/升级流程

1. 部署新模块的 Implementation 合约（可部署多个模块）
2. 将新模块的地址数组传入 Installer Proxy，调用 InstallModules()函数
3. 函数内部会遍历这些模块，并为其创建模块的 ModuleProxy 合约
4. 将每个新模块的 Implementation 和 ModuleProxy 绑定(mapping)，完成新模块安装

![](https://github.com/0x-stan/euler-module-proxy/blob/main/img/Euler-module-proxy-03.png)

### 用户调用模块功能接口流程

1. 向模块的 ModuleProxy 发起调用(注意不是 MainProxy)
2. ModuleProxy 会使用 call 操作码来调用 MainProxy 的 dispatch 函数
3. dispatch 函数会使用 delegatecall 操作码来调用模块的 Implementation 执行逻辑合约

![](https://github.com/0x-stan/euler-module-proxy/blob/main/img/Euler-module-proxy-04.png)

调用过程非常绕，但是这么做有很大的优势。由于最终是由 MainProxy 使用 delegatecall 调用具体逻辑，所以 Euler 合约的主要状态都存储在主入口代理合约 MainProxy 上，而模块的安装/升级并不会影响协议的状态。

### 主要代码逻辑

下面来看一下主要的代码逻辑，首先是 ModuleProxy 的 fallback，当我们发起调用时，会进入这里的 assembly 代码块，会先将我们的 calldata 重组：

```bash
dispatch selector + calldata + caller address
```

然后使用 call 操作码调用 MainProxy，由于所有模块的 Proxy 都是由 MainProxy 创建，所以模块 Proxy 的 creator 就是 MainProxy

![](https://github.com/0x-stan/euler-module-proxy/blob/main/img/Euler-module-proxy-05.png)

接下来进入 MainProxy 的 dispatch 函数，首先会检查 calldata 长度，因为从 ModuleProxy 发送过来的调用都会进行重组，所以合法的调用长度是大于等于 28 字节

```bash
4 dispatch selector+4 some function selector + (payload) + 20 caller address
```

接着使用 delegatecall 操作码调用模块的执行逻辑合约

![](https://github.com/0x-stan/euler-module-proxy/blob/main/img/Euler-module-proxy-06.png)

> 注意：ModuleProxy 中使用 call 调用，而 MainProxy 中使用 delegatecall 调用，所以函数运行逻辑在模块的 Implementation 中，而所使用的状态在 MainProxy 中

还有一个很精彩的地方：event log 记录在模块的 Proxy 中。在 fallback 中有一个条件语句，当使用模块中类似 emitViaProxy_Transfer 函数发出 event log 时，日志会被分门别类的记录在不同模块的 Proxy 中，而不会全部堆叠在 MainProxy 中。

![](https://github.com/0x-stan/euler-module-proxy/blob/main/img/Euler-module-proxy-07.png)

![](https://github.com/0x-stan/euler-module-proxy/blob/main/img/Euler-module-proxy-08.png)

## Flow

![Flow Board](https://whimsical.com/euler-module-proxy-BhhPNejt2rbLgx1jntXAsh)

![Euler-Module-Proxy-Flow](./img/Euler-Module-Proxy%402x.png)
