# Route Processor

> Stateless, modular execution engine for composable DeFi routing

A highly gas-optimized, stateless route execution engine for executing complex token swaps across multiple DeFi protocols in a single atomic transaction.

## Table of Contents

-   [Overview](#overview)
-   [Key Features](#key-features)
-   [Supported Protocols](#supported-protocols)
    -   [DEX Protocols](#dex-protocols)
    -   [Liquid Staking Tokens (LST)](#liquid-staking-tokens-lst)
    -   [Liquid Restaking Tokens (LRT)](#liquid-restaking-tokens-lrt)
-   [Architecture](#architecture)
    -   [Core Components](#core-components)
    -   [Command System](#command-system)
    -   [Protocol Identifiers](#protocol-identifiers)
    -   [Asset Types](#asset-types)
-   [Usage](#usage)
    -   [Installation](#installation)
    -   [Project Structure](#project-structure)
    -   [Permit2 Commands](#permit2-commands)
    -   [Sweep Command](#sweep-command)
    -   [WETH/LST/LRT Operations](#wethlstlrt-operations)
    -   [Basic Swap Executions](#basic-swap-executions)
    -   [Multi-Hop Routes](#multi-hop-routes)
-   [Testing](#testing)
    -   [Test Structure](#test-structure)
-   [Security Considerations](#security-considerations)
    -   [Built-in Protections](#built-in-protections)
    -   [Known Considerations](#known-considerations)
-   [Gas Optimization Techniques](#gas-optimization-techniques)
-   [Resources](#resources)
-   [Acknowledgments](#acknowledgments)

---

## Overview

**RouteProcessor** is a modular swap aggregator built with Foundry that enables seamless token exchanges across:

-   **Uniswap V2**
-   **Uniswap V3**
-   **Curve Finance**
-   **Liquid Staking Tokens (LST)** - Lido, Rocket Pool, Frax, Swell, Binance, Stader, StakeWise, Ether.fi, Origin, Ankr
-   **Liquid Restaking Tokens (LRT)** - Renzo, Puffer, Mantle

The protocol interprets encoded command streams to execute multi-hop routes with maximum efficiency, utilizing inline assembly optimizations and transient storage for callback validation.

## Key Features

-   **Multi-Protocol Support** - Single interface for Curve, Uniswap V2/V3, and 10+ LST/LRT protocols
-   **Gas Optimized** - Assembly-level optimizations with efficient calldata encoding
-   **Security** - Reentrancy protection, deadline validation, and callback authentication
-   **Multi-Hop Routes** - Execute complex paths across different protocols in one transaction
-   **Permit2 Integration** - Gasless approvals via Uniswap's Permit2 contract
-   **Native ETH Support** - Seamless handling of both ERC20 tokens and native ETH
-   **Stateless Design** - No storage dependencies, all execution state lives in calldata

## Supported Protocols

### DEX Protocols

-   **Uniswap V2** (SushiSwap V2, PancakeSwap V2, etc.)
-   **Uniswap V3** (SushiSwap V3, PancakeSwap V3, etc.)
-   **Curve Finance**

### Liquid Staking Tokens (LST)

-   **Lido** - stETH, wstETH
-   **Rocket Pool** - rETH
-   **Frax Ether** - frxETH, sfrxETH
-   **Swell** - swETH
-   **Binance** - wBETH
-   **Stader** - ETHx
-   **StakeWise** - osETH
-   **Ether.fi** - eETH, weETH
-   **Origin** - OETH, WOETH
-   **Ankr** - ankrETH, aETHb

#### Liquid Restaking Tokens (LRT)

-   **Mantle** - mETH, cmETH
-   **Renzo** - ezETH, pzETH
-   **Puffer** - pufETH

## Architecture

### Core Components

```
RouteProcessor (Main Entry Point)
├── NativeWrapper      → WETH/LST/LRT operations
├── Permit2Forwarder   → Permit2 integration
├── CurveRoute         → Curve integration
├── V2Route            → Uniswap V2 integration
├── V3Route            → Uniswap V3 integration
└── ReentrancyGuard    → Reentrancy protection
```

### Command System

Routes are encoded as byte streams containing commands:

| Command                       | Opcode | Description                                   |
| ----------------------------- | ------ | --------------------------------------------- |
| `SWAP`                        | `0x00` | Execute swap route (V2/V3/Curve/WETH/LST/LRT) |
| `PERMIT2_PERMIT`              | `0x01` | Single-token permit approval via Permit2      |
| `PERMIT2_PERMIT_BATCH`        | `0x02` | Batch-token permit approval via Permit2       |
| `PERMIT2_TRANSFER_FROM`       | `0x03` | Single-token transfer via Permit2             |
| `PERMIT2_TRANSFER_FROM_BATCH` | `0x04` | Batch-token transfer via Permit2              |
| `SWEEP`                       | `0x05` | Transfer remaining contract balance           |

[Commands.sol](https://github.com/fomoweth/route-processor/blob/main/src/libraries/Commands.sol)

### Protocol Identifiers

Each protocol is identified by a single byte in the route encoding:

| Protocol    | ID     | Type    | Description                                  |
| ----------- | ------ | ------- | -------------------------------------------- |
| `WETH`      | `0x00` | WETH    | Wrapped Ether (ETH ↔ WETH)                   |
| `Curve`     | `0x01` | DEX     | Curve Finance AMMs                           |
| `UniswapV2` | `0x02` | DEX     | Uniswap V2 AMMs (constant product)           |
| `UniswapV3` | `0x03` | DEX     | Uniswap V3 AMMs (concentrated liquidity)     |
| `Rocket`    | `0x04` | LST     | Rocket Pool (rETH)                           |
| `Swell`     | `0x05` | LST     | Swell Network (swETH)                        |
| `Binance`   | `0x06` | LST     | Binance Staking (wBETH)                      |
| `Stader`    | `0x07` | LST     | Stader Labs (ETHx)                           |
| `StakeWise` | `0x08` | LST     | StakeWise (osETH)                            |
| `Lido`      | `0x09` | LST     | Lido Finance (stETH, wstETH)                 |
| `EtherFi`   | `0x0a` | LST     | Ether.fi (eETH, weETH)                       |
| `Frax`      | `0x0b` | LST     | Frax Ether (frxETH, sfrxETH)                 |
| `Origin`    | `0x0c` | LST     | Origin Protocol (OETH, WOETH)                |
| `Ankr`      | `0x0d` | LST     | Ankr Liquid Staking (ankrETH, aETHb)         |
| `Mantle`    | `0x0e` | LST/LRT | Mantle Liquid Staking Platform (mETH, cmETH) |
| `Renzo`     | `0x0f` | LRT     | Renzo Protocol (ezETH, pzETH)                |
| `Puffer`    | `0x10` | LRT     | Puffer Finance (pufETH)                      |

### Asset Types

| Type   | ID     | Description                  |
| ------ | ------ | ---------------------------- |
| `ETH`  | `0x00` | Native Ether                 |
| `WETH` | `0x01` | Wrapped Ether                |
| `LST`  | `0x02` | Liquid Staking Token         |
| `WLST` | `0x03` | Wrapped Liquid Staking Token |
| `LRT`  | `0x04` | Liquid Restaking Token       |

[Enums.sol](https://github.com/fomoweth/route-processor/blob/main/src/types/Enums.sol)

## Usage

### Installation

```bash
# Clone the repository
git clone https://github.com/fomoweth/route-processor.git

cd route-processor

# Install dependencies
forge install

# Build the project
forge build
```

### Project Structure

```
src/
├── interfaces/
│   └── IRouteProcessor.sol       → Main interface
├── libraries/
│   ├── Commands.sol              → Command opcodes
│   ├── Errors.sol                → Custom errors
│   └── SafeTransferLib.sol       → Safe token transfers
├── modules/
│   ├── CurveRoute.sol            → Curve integration
│   ├── NativeWrapper.sol         → WETH/LST/LRT operations
│   ├── Permit2Forwarder.sol      → Permit2 integration
│   ├── V2Route.sol               → Uniswap V2 integration
│   └── V3Route.sol               → Uniswap V3 integration
├── types/
│   ├── Enums.sol                 → Protocol & asset types
│   └── Stream.sol                → Calldata stream parser
├── utils/
│   ├── CallbackValidation.sol    → V3 callback auth
│   └── ReentrancyGuard.sol       → Reentrancy protection
└── RouteProcessor.sol            → Main contract
```

### Permit2 Commands

<details open>
<summary><strong>Permit Single</strong></summary>

```solidity
PermitDetails memory details = PermitDetails({
    token: ...,
    amount: ...,
    expiration: ...,
    nonce: ...
});

uint256 word = (uint256(details.nonce) << 208) | (uint256(details.expiration) << 160) | uint256(details.amount);

uint256 sigDeadline = ...

bytes memory signature = ...

bytes memory cmd = abi.encodePacked(
    Commands.PERMIT2_PERMIT,
    token,
    word,
    sigDeadline,
    signature.length,
    signature
);
```

</details>

<details open>
<summary><strong>Permit Batch</strong></summary>

```solidity
PermitDetails[] memory details = new PermitDetails[](n);

for (uint256 i = 0; i < details.length; ++i) {
    details[i] = PermitDetails({
        token: ...,
        amount: ...,
        expiration: ...,
        nonce: ...
    });
}

bytes memory encoded = abi.encode(details);

uint256 sigDeadline = ...

bytes memory signature = ...

bytes memory cmd = abi.encodePacked(
    Commands.PERMIT2_PERMIT_BATCH,
    encoded.length,
    encoded,
    sigDeadline,
    signature.length,
    signature
);
```

</details>

<details open>
<summary><strong>TransferFrom</strong></summary>

```solidity
bytes memory cmd = abi.encodePacked(Commands.PERMIT2_TRANSFER_FROM, token, uint160(amount));
```

</details>

<details open>
<summary><strong>Batch TransferFrom</strong></summary>

```solidity
AllowanceTransferDetails[] memory transferDetails = new AllowanceTransferDetails[](n);

for (uint256 i = 0; i < transferDetails.length; ++i) {
    transferDetails[i] = AllowanceTransferDetails({
        from: msg.sender, // must be the sender
        to: address(routeProcessor), // must be the RouteProcessor
        amount: ...,
        token: ...
    });
}

bytes memory encoded = abi.encode(transferDetails);

bytes memory cmd = abi.encodePacked(
    Commands.PERMIT2_TRANSFER_FROM_BATCH,
    encoded.length,
    encoded
);
```

</details>

### Sweep Command

<details open>
<summary><strong>Sweep</strong></summary>

```solidity
bytes memory cmd = abi.encodePacked(Commands.SWEEP, token, recipient, amount);
```

</details>

### WETH/LST/LRT Operations

<details>
<summary><strong>WETH</strong></summary>

<ul>
    <li>WETH: <a href="https://etherscan.io/address/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2">0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2</a></li>
</ul>

<code>ETH → WETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.WETH,
    address(0), // zero address for pool
    WETH,
    AssetType.ETH,
    AssetType.WETH
);

routeProcessor.processRoute{value: msg.value}(route);
```

<code>WETH → ETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    WETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.WETH,
    address(0), // zero address for pool
    ETH,
    AssetType.WETH,
    AssetType.ETH
);

routeProcessor.processRoute(route);
```

</details>

<details>
<summary><strong>Rocket Pool</strong> (rETH)</summary>

<ul>
    <li>rETH: <a href="https://etherscan.io/address/0xae78736Cd615f374D3085123A210448E74Fc6393">0xae78736Cd615f374D3085123A210448E74Fc6393</a></li>
    <li>RocketDepositPool: <a href="https://etherscan.io/address/0xDD3f50F8A6CafbE9b31a427582963f465E745AF8">0xDD3f50F8A6CafbE9b31a427582963f465E745AF8</a></li>
</ul>

<code>ETH → rETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Rocket,
    RocketDepositPool,
    rETH,
    AssetType.ETH,
    AssetType.LST
);

routeProcessor.processRoute{value: msg.value}(route);
```

</details>

<details>
<summary><strong>Swell</strong> (swETH)</summary>

<ul>
    <li>swETH: <a href="https://etherscan.io/address/0xf951E335afb289353dc249e82926178EaC7DEd78">0xf951E335afb289353dc249e82926178EaC7DEd78</a></li>
</ul>

<code>ETH → swETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Swell,
    address(0), // zero address for pool
    swETH,
    AssetType.ETH,
    AssetType.LST
);

routeProcessor.processRoute{value: msg.value}(route);
```

</details>

<details>
<summary><strong>Binance</strong> (wBETH)</summary>

<ul>
    <li>wBETH: <a href="https://etherscan.io/address/0xa2E3356610840701BDf5611a53974510Ae27E2e1">0xa2E3356610840701BDf5611a53974510Ae27E2e1</a></li>
</ul>

<code>ETH → wBETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Binance,
    address(0), // zero address for pool
    wBETH,
    AssetType.ETH,
    AssetType.LST
);

routeProcessor.processRoute{value: msg.value}(route);
```

</details>

<details>
<summary><strong>Stader</strong> (ETHx)</summary>

<ul>
    <li>ETHx: <a href="https://etherscan.io/address/0xA35b1B31Ce002FBF2058D22F30f95D405200A15b">0xA35b1B31Ce002FBF2058D22F30f95D405200A15b</a></li>
    <li>StaderStakePoolsManager: <a href="https://etherscan.io/address/0xcf5EA1b38380f6aF39068375516Daf40Ed70D299">0xcf5EA1b38380f6aF39068375516Daf40Ed70D299</a></li>
</ul>

<code>ETH → ETHx</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Stader,
    StaderStakePoolsManager,
    ETHx,
    AssetType.ETH,
    AssetType.LST
);

routeProcessor.processRoute{value: msg.value}(route);
```

</details>

<details>
<summary><strong>StakeWise</strong> (osETH)</summary>

<ul>
    <li>osETH: <a href="https://etherscan.io/address/0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38">0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38</a></li>
    <li>EthGenesisVault: <a href="https://etherscan.io/address/0xAC0F906E433d58FA868F936E8A43230473652885">0xAC0F906E433d58FA868F936E8A43230473652885</a></li>
</ul>

<code>ETH → osETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.StakeWise,
    EthGenesisVault,
    osETH,
    AssetType.ETH,
    AssetType.LST
);

routeProcessor.processRoute{value: msg.value}(route);
```

</details>

<details>
<summary><strong>Lido</strong> (stETH, wstETH)</summary>

<ul>
    <li>stETH: <a href="https://etherscan.io/address/0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84">0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84</a></li>
    <li>wstETH: <a href="https://etherscan.io/address/0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0">0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0</a></li>
</ul>

<code>ETH → stETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Lido,
    address(0), // zero address for pool
    stETH,
    AssetType.ETH,
    AssetType.LST
);

routeProcessor.processRoute{value: msg.value}(route);
```

<code>ETH → wstETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Lido,
    address(0), // zero address for pool
    wstETH,
    AssetType.ETH,
    AssetType.WLST
);

routeProcessor.processRoute{value: msg.value}(route);
```

<code>stETH → wstETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    stETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Lido,
    address(0), // zero address for pool
    wstETH,
    AssetType.LST,
    AssetType.WLST
);

routeProcessor.processRoute(route);
```

<code>wstETH → stETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    wstETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Lido,
    address(0), // zero address for pool
    stETH,
    AssetType.WLST,
    AssetType.LST
);

routeProcessor.processRoute(route);
```

</details>

<details>
<summary><strong>Ether.fi</strong> (eETH, weETH)</summary>

<ul>
    <li>eETH: <a href="https://etherscan.io/address/0x35fA164735182de50811E8e2E824cFb9B6118ac2">0x35fA164735182de50811E8e2E824cFb9B6118ac2</a></li>
    <li>weETH: <a href="https://etherscan.io/address/0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee">0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee</a></li>
    <li>LiquidityPool: <a href="https://etherscan.io/address/0x308861A430be4cce5502d0A12724771Fc6DaF216">0x308861A430be4cce5502d0A12724771Fc6DaF216</a></li>
</ul>

<code>ETH → eETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.EtherFi,
    LiquidityPool,
    eETH,
    AssetType.ETH,
    AssetType.LST
);

routeProcessor.processRoute{value: msg.value}(route);
```

<code>ETH → weETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.EtherFi,
    LiquidityPool,
    weETH,
    AssetType.ETH,
    AssetType.WLST
);

routeProcessor.processRoute{value: msg.value}(route);
```

<code>eETH → weETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    eETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.EtherFi,
    address(0), // zero address for pool
    weETH,
    AssetType.LST,
    AssetType.WLST
);

routeProcessor.processRoute(route);
```

<code>weETH → eETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    weETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.EtherFi,
    address(0), // zero address for pool
    eETH,
    AssetType.WLST,
    AssetType.LST
);

routeProcessor.processRoute(route);
```

</details>

<details>
<summary><strong>Frax</strong> (frxETH, sfrxETH)</summary>

<ul>
    <li>frxETH: <a href="https://etherscan.io/address/0x5E8422345238F34275888049021821E8E08CAa1f">0x5E8422345238F34275888049021821E8E08CAa1f</a></li>
    <li>sfrxETH: <a href="https://etherscan.io/address/0xac3E018457B222d93114458476f3E3416Abbe38F">0xac3E018457B222d93114458476f3E3416Abbe38F</a></li>
    <li>frxETHMinter: <a href="https://etherscan.io/address/0xbAFA44EFE7901E04E39Dad13167D089C559c1138">0xbAFA44EFE7901E04E39Dad13167D089C559c1138</a></li>
</ul>

<code>ETH → frxETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Frax,
    frxETHMinter,
    frxETH,
    AssetType.ETH,
    AssetType.LST
);

routeProcessor.processRoute{value: msg.value}(route);
```

<code>ETH → sfrxETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Frax,
    frxETHMinter,
    sfrxETH,
    AssetType.ETH,
    AssetType.WLST
);

routeProcessor.processRoute{value: msg.value}(route);
```

<code>frxETH → sfrxETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    frxETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Frax,
    address(0), // zero address for pool
    sfrxETH,
    AssetType.LST,
    AssetType.WLST
);

routeProcessor.processRoute(route);
```

<code>sfrxETH → frxETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    sfrxETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Frax,
    address(0), // zero address for pool
    frxETH,
    AssetType.WLST,
    AssetType.LST
);

routeProcessor.processRoute(route);
```

</details>

<details>
<summary><strong>Origin</strong> (OETH, WOETH)</summary>

<ul>
    <li>WETH: <a href="https://etherscan.io/address/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2">0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2</a></li>
    <li>OETH: <a href="https://etherscan.io/address/0x856c4Efb76C1D1AE02e20CEB03A2A6a08b0b8dC3">0x856c4Efb76C1D1AE02e20CEB03A2A6a08b0b8dC3</a></li>
    <li>WOETH: <a href="https://etherscan.io/address/0xDcEe70654261AF21C44c093C300eD3Bb97b78192">0xDcEe70654261AF21C44c093C300eD3Bb97b78192</a></li>
    <li>OETHVault: <a href="https://etherscan.io/address/0x39254033945AA2E4809Cc2977E7087BEE48bd7Ab">0x39254033945AA2E4809Cc2977E7087BEE48bd7Ab</a></li>
</ul>

<code>WETH → OETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    WETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Origin,
    OETHVault,
    OETH,
    AssetType.WETH,
    AssetType.LST
);

routeProcessor.processRoute(route);
```

<code>WETH → WOETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    WETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Origin,
    OETHVault,
    WOETH,
    AssetType.WETH,
    AssetType.WLST
);

routeProcessor.processRoute(route);
```

<code>OETH → WOETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    OETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Origin,
    address(0), // zero address for pool
    WOETH,
    AssetType.LST,
    AssetType.WLST
);

routeProcessor.processRoute(route);
```

<code>WOETH → OETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    WOETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Origin,
    address(0), // zero address for pool
    OETH,
    AssetType.WLST,
    AssetType.LST
);

routeProcessor.processRoute(route);
```

</details>

<details>
<summary><strong>Ankr</strong> (ankrETH, aETHb)</summary>

<ul>
    <li>ankrETH: <a href="https://etherscan.io/address/0xE95A203B1a91a908F9B9CE46459d101078c2c3cb">0xE95A203B1a91a908F9B9CE46459d101078c2c3cb</a></li>
    <li>aETHb: <a href="https://etherscan.io/address/0xD01ef7C0A5d8c432fc2d1a85c66cF2327362E5C6">0xD01ef7C0A5d8c432fc2d1a85c66cF2327362E5C6</a></li>
    <li>GlobalPool: <a href="https://etherscan.io/address/0x84db6eE82b7Cf3b47E8F19270abdE5718B936670">0x84db6eE82b7Cf3b47E8F19270abdE5718B936670</a></li>
</ul>

<code>ETH → ankrETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Ankr,
    GlobalPool,
    ankrETH,
    AssetType.ETH,
    AssetType.LST
);

routeProcessor.processRoute{value: msg.value}(route);
```

<code>ETH → aETHb</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Ankr,
    GlobalPool,
    aETHb,
    AssetType.ETH,
    AssetType.WLST
);

routeProcessor.processRoute{value: msg.value}(route);
```

<code>ankrETH → aETHb</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    ankrETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Ankr,
    address(0), // zero address for pool
    aETHb,
    AssetType.LST,
    AssetType.WLST
);

routeProcessor.processRoute(route);
```

<code>aETHb → ankrETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    aETHb,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Ankr,
    address(0), // zero address for pool
    ankrETH,
    AssetType.WLST,
    AssetType.LST
);

routeProcessor.processRoute(route);
```

</details>

<details>
<summary><strong>Mantle</strong> (mETH, cmETH)</summary>

<ul>
    <li>mETH: <a href="https://etherscan.io/address/0xd5F7838F5C461fefF7FE49ea5ebaF7728bB0ADfa">0xd5F7838F5C461fefF7FE49ea5ebaF7728bB0ADfa</a></li>
    <li>cmETH: <a href="https://etherscan.io/address/0xE6829d9a7eE3040e1276Fa75293Bde931859e8fA">0xE6829d9a7eE3040e1276Fa75293Bde931859e8fA</a></li>
    <li>Staking: <a href="https://etherscan.io/address/0xe3cBd06D7dadB3F4e6557bAb7EdD924CD1489E8f">0xe3cBd06D7dadB3F4e6557bAb7EdD924CD1489E8f</a></li>
    <li>Teller: <a href="https://etherscan.io/address/0xB6f7D38e3EAbB8f69210AFc2212fe82e0f1912b0">0xB6f7D38e3EAbB8f69210AFc2212fe82e0f1912b0</a></li>
</ul>

<code>ETH → mETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Mantle,
    Staking,
    mETH,
    AssetType.ETH,
    AssetType.LST
);

routeProcessor.processRoute{value: msg.value}(route);
```

<code>ETH → cmETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Mantle,
    Teller,
    cmETH,
    AssetType.ETH,
    AssetType.LRT
);

routeProcessor.processRoute{value: msg.value}(route);
```

<code>mETH → cmETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    mETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Mantle,
    Teller,
    cmETH,
    AssetType.LST,
    AssetType.LRT
);

routeProcessor.processRoute(route);
```

</details>

<details>
<summary><strong>Renzo</strong> (ezETH, pzETH)</summary>

<ul>
    <li>stETH: <a href="https://etherscan.io/address/0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84">0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84</a></li>
    <li>wstETH: <a href="https://etherscan.io/address/0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0">0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0</a></li>
    <li>ezETH: <a href="https://etherscan.io/address/0xbf5495Efe5DB9ce00f80364C8B423567e58d2110">0xbf5495Efe5DB9ce00f80364C8B423567e58d2110</a></li>
    <li>pzETH: <a href="https://etherscan.io/address/0x8c9532a60E0E7C6BbD2B2c1303F63aCE1c3E9811">0x8c9532a60E0E7C6BbD2B2c1303F63aCE1c3E9811</a></li>
    <li>RestakeManager: <a href="https://etherscan.io/address/0x74a09653A083691711cF8215a6ab074BB4e99ef5">0x74a09653A083691711cF8215a6ab074BB4e99ef5</a></li>
</ul>

<code>ETH → ezETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Renzo,
    RestakeManager,
    ezETH,
    AssetType.ETH,
    AssetType.LST
);

routeProcessor.processRoute{value: msg.value}(route);
```

<code>stETH → ezETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    stETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Renzo,
    RestakeManager,
    ezETH,
    AssetType.LST,
    AssetType.LRT
);

routeProcessor.processRoute(route);
```

<code>wstETH → pzETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    wstETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Renzo,
    address(0), // zero address for pool
    pzETH,
    AssetType.WLST,
    AssetType.LRT
);

routeProcessor.processRoute(route);
```

</details>

<details>
<summary><strong>Puffer</strong> (pufETH)</summary>

<ul>
    <li>WETH: <a href="https://etherscan.io/address/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2">0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2</a></li>
    <li>stETH: <a href="https://etherscan.io/address/0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84">0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84</a></li>
    <li>pufETH: <a href="https://etherscan.io/address/0xD9A442856C234a39a81a089C06451EBAa4306a72">0xD9A442856C234a39a81a089C06451EBAa4306a72</a></li>
</ul>

<code>ETH → pufETH</code>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    ETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Puffer,
    address(0), // zero address for pool
    pufETH,
    AssetType.ETH,
    AssetType.LRT
);

routeProcessor.processRoute{value: msg.value}(route);
```

<code>WETH → pufETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    WETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Puffer,
    address(0), // zero address for pool
    pufETH,
    AssetType.WETH,
    AssetType.LRT
);

routeProcessor.processRoute(route);
```

<code>stETH → pufETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    stETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Puffer,
    address(0), // zero address for pool
    pufETH,
    AssetType.LST,
    AssetType.LRT
);

routeProcessor.processRoute(route);
```

<code>pufETH → WETH</code>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    pufETH,
    amountIn,
    amountOutMin,
    uint8(1), // number of hops
    Protocol.Puffer,
    address(0), // zero address for pool
    WETH,
    AssetType.LRT,
    AssetType.WETH
);

routeProcessor.processRoute(route);
```

</details>

### Basic Swap Executions

<details open>
<summary><strong>ETH → USDC via Uniswap V2</strong></summary>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    tokenIn, // ETH
    amountIn,
    amountOutMin,
    uint8(2), // number of hops (2 = ETH → WETH → USDC)

    // ETH → WETH
    Protocol.WETH,
    address(0), // zero address for pool
    WETH,
    AssetType.ETH,
    AssetType.WETH,

    // WETH → USDC
    Protocol.UniswapV2,
    pool, // USDC/WETH: 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc
    tokenOut, // USDC
    uint24(0) // pool fee default to: 3000
);

routeProcessor.processRoute{value: msg.value}(route);
```

</details>

<details open>
<summary><strong>ETH → USDC via Uniswap V3</strong></summary>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    tokenIn, // ETH
    amountIn,
    amountOutMin,
    uint8(2), // number of hops (2 = ETH → WETH → USDC)

    // ETH → WETH
    Protocol.WETH,
    address(0), // zero address for pool
    WETH,
    AssetType.ETH,
    AssetType.WETH,

    // WETH → USDC
    Protocol.UniswapV3,
    pool, // USDC/WETH: 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640
    tokenOut, // USDC
    bytes4(0) // callback selector default to: 0xfa461e33
);

routeProcessor.processRoute{value: msg.value}(route, deadline);
```

</details>

<details open>
<summary><strong>ETH → USDC via Curve</strong></summary>

```solidity
bytes memory route = abi.encodePacked(
    Commands.SWAP,
    recipient,
    tokenIn, // ETH
    amountIn,
    amountOutMin,
    uint8(1), // number of hops

    // ETH → USDC
    Protocol.Curve,
    pool, // TricryptoUSDC: 0x7F86Bf177Dd4F3494b841a37e810A34dD56c829B
    tokenOut, // USDC
    uint8(2), // i
    uint8(0), // j
    true, // isCryptoPool
    false, // useUnderlying
    true // useEth
);

routeProcessor.processRoute{value: msg.value}(route, deadline);
```

</details>

### Multi-Hop Routes

<details open>
<summary><strong>Mixed Route (WETH → wstETH → sfrxETH → frxETH)</strong></summary>

```solidity
bytes memory route = abi.encodePacked(
    permitCmd,
    transferCmd,
    Commands.SWAP,
    recipient,
    tokenIn, // WETH
    amountIn,
    amountOutMin,
    uint8(3), // number of hops (3 = WETH → wstETH → sfrxETH → frxETH)

    // WETH → wstETH
    Protocol.UniswapV3,
    UNI_V3_POOL, // wstETH/WETH: 0x109830a1AAaD605BbF02a9dFA7B0B92EC2FB7dAa
    wstETH,
    bytes4(0), // callback selector default to: 0xfa461e33

    // wstETH → sfrxETH
    Protocol.Curve,
    CURVE_POOL, // TryLSD: 0x2570f1bD5D2735314FC102eb12Fc1aFe9e6E7193
    sfrxETH,
    uint8(0), // i
    uint8(2), // j
    true, // isCryptoPool
    false, // useUnderlying
    false, // useEth

    // sfrxETH → frxETH
    Protocol.Frax,
    address(0), // zero address for pool
    frxETH,
    AssetType.WLST,
    AssetType.LST
);

routeProcessor.processRoute(route, deadline);
```

</details>

<details open>
<summary><strong>Split Routes (ETH → wstETH)</strong></summary>

```solidity
bytes memory v2Route = abi.encodePacked(
    Commands.SWAP,
    address(2), // equivalent to `address(this)`
    tokenIn, // ETH
    amountIn,
    amountOutMin,
    uint8(2), // number of hops (2 = ETH → WETH → stETH)

    // ETH → WETH
    Protocol.WETH,
    address(0), // zero address for pool
    WETH,
    AssetType.ETH,
    AssetType.WETH,

    // WETH → stETH
    Protocol.UniswapV2,
    UNI_V2_POOL, // stETH/WETH: 0x4028DAAC072e492d34a3Afdbef0ba7e35D8b55C4
    stETH,
    uint24(3000) // pool fee for Uniswap V2 pairs
);

bytes memory v3Route = abi.encodePacked(
    Commands.SWAP,
    address(1), // equivalent to `msg.sender`
    tokenIn, // ETH
    amountIn,
    amountOutMin,
    uint8(2), // number of hops (2 = ETH → WETH → wstETH)

    // ETH → WETH
    Protocol.WETH,
    address(0), // zero address for pool
    WETH,
    AssetType.ETH,
    AssetType.WETH,

    // WETH → wstETH
    Protocol.UniswapV3,
    UNI_V3_POOL, // wstETH/WETH: 0x109830a1AAaD605BbF02a9dFA7B0B92EC2FB7dAa
    wstETH,
    bytes4(0xfa461e33) // callback selector for Uniswap V3 pools
);

bytes memory crvRoute = abi.encodePacked(
    Commands.SWAP,
    address(2), // equivalent to `address(this)`
    tokenIn, // ETH
    amountIn,
    amountOutMin,
    uint8(1), // number of hops

    // ETH → stETH
    Protocol.Curve,
    CURVE_POOL, // ETH/stETH: 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022
    stETH,
    uint8(0), // i
    uint8(1), // j
    false, // isCryptoPool
    false, // useUnderlying
    false // useEth
);

bytes memory wrapCmd = abi.encodePacked(
    Commands.SWAP,
    address(1), // equivalent to `msg.sender`
    stETH,
    CONTRACT_BALANCE, // 0x8000000000000000000000000000000000000000000000000000000000000000
    amountOutMin,
    uint8(1), // number of hops

    // stETH → wstETH
    Protocol.Lido,
    address(0), // zero address for pool
    wstETH,
    AssetType.LST,
    AssetType.WLST
);

bytes memory route = bytes.concat(v2Route, v3Route, crvRoute, wrapCmd);

routeProcessor.processRoute{value: msg.value}(route, deadline);
```

</details>

<details open>
<summary><strong>Split Routes (wstETH, weETH, sfrxETH → ETH)</strong></summary>

```solidity
address[] memory tokens = new address[](3);
tokens[0] = wstETH;
tokens[1] = weETH;
tokens[2] = frxETH;

uint160[] memory amounts = ...

PermitDetails[] memory _details = new PermitDetails[](tokens.length);

AllowanceTransferDetails[] memory _transferDetails = new AllowanceTransferDetails[](tokens.length);

for (uint256 i = 0; i < tokens.length; ++i) {
    _details[i] = PermitDetails({
        token: tokens[i],
        amount: amounts[i],
        expiration: ...,
        nonce: ...
    });

    _transferDetails[i] = AllowanceTransferDetails({
        from: msg.sender, // must be the sender
        to: address(routeProcessor), // must be the RouteProcessor
        amount: amounts[i],
        token: tokens[i]
    });
}

bytes memory details = abi.encode(_details);

bytes memory transferDetails = abi.encode(_transferDetails);

uint256 sigDeadline = ...

bytes memory signature = ...

bytes memory permitCmd = abi.encodePacked(
    Commands.PERMIT2_PERMIT_BATCH,
    details.length,
    details,
    sigDeadline,
    signature.length,
    signature
);

bytes memory transferCmd = abi.encodePacked(
    Commands.PERMIT2_TRANSFER_FROM_BATCH,
    transferDetails.length,
    transferDetails
);

bytes memory v2Route = abi.encodePacked(
    Commands.SWAP,
    address(2), // equivalent to `address(this)`
    tokens[0], // wstETH
    amounts[0],
    amountOutMin,
    uint8(2), // number of hops (2 = wstETH → stETH → WETH)

    // wstETH → stETH
    Protocol.Lido,
    address(0), // zero address for pool
    stETH,
    AssetType.WLST,
    AssetType.LST,

    // stETH → WETH
    Protocol.UniswapV2,
    UNI_V2_POOL, // stETH/WETH: 0x4028DAAC072e492d34a3Afdbef0ba7e35D8b55C4
    WETH,
    uint24(3000) // pool fee
);

bytes memory v3Route = abi.encodePacked(
    Commands.SWAP,
    address(2), // equivalent to `address(this)`
    tokens[1], // weETH
    amounts[1],
    amountOutMin,
    uint8(1), // number of hops

    // weETH → WETH
    Protocol.UniswapV3,
    UNI_V3_POOL, // WETH/weETH: 0x202A6012894Ae5c288eA824cbc8A9bfb26A49b93
    WETH,
    bytes4(0xfa461e33), // callback selector
);

bytes memory crvRoute = abi.encodePacked(
    Commands.SWAP,
    address(2), // equivalent to `address(this)`
    tokens[2], // sfrxETH
    amounts[2],
    amountIn,
    amountOutMin,
    uint8(2), // number of hops (2 = sfrxETH → frxETH → WETH)

    // sfrxETH → frxETH
    Protocol.Frax,
    address(0), // zero address for pool
    frxETH,
    AssetType.WLST,
    AssetType.LST,

    // frxETH → WETH
    Protocol.Curve,
    CURVE_POOL, // WETH/frxETH: 0x9c3B46C0Ceb5B9e304FCd6D88Fc50f7DD24B31Bc
    WETH,
    uint8(1), // i
    uint8(0), // j
    false, // isCryptoPool
    false, // useUnderlying
    false // useEth
);

bytes memory unwrapCmd = abi.encodePacked(
    Commands.SWAP,
    address(1), // equivalent to `msg.sender`
    WETH,
    CONTRACT_BALANCE, // 0x8000000000000000000000000000000000000000000000000000000000000000
    amountOutMin,
    uint8(1), // number of hops

    Protocol.WETH,
    address(0), // zero address for pool
    ETH,
    AssetType.WETH,
    AssetType.ETH
);

bytes memory route = bytes.concat(permitCmd, transferCmd, v2Route, v3Route, crvRoute, unwrapCmd);

routeProcessor.processRoute(route, deadline);
```

</details>

## Testing

```bash
# Run all tests (tests run on mainnet fork at block 23265742)
forge test

# Run tests with verbosity (-vvv for detailed traces)
forge test -vvv

# Run specific test file
forge test --match-path test/modules/V3Route.t.sol
```

### Test Structure

The project includes comprehensive test coverage across all modules with 100+ test cases covering edge cases, multi-hop routes, and complex scenarios.

```
test/
├── modules/
│   ├── curve/                            → (Curve AMMs)
│   │   ├── CurveRouteCryptoPool.t.sol
│   │   ├── CurveRouteLendingPool.t.sol
│   │   ├── CurveRouteMetaPool.t.sol
│   │   └── CurveRouteStablePool.t.sol
│   ├── native/
│   │   ├── NativeWrapper.t.sol           → (WETH, rETH, swETH, wBETH, ETHx, osETH)
│   │   ├── NativeWrapperLido.t.sol       → (stETH, wstETH)
│   │   ├── NativeWrapperAnkr.t.sol       → (ankrETH, aETHb)
│   │   ├── NativeWrapperEtherFi.t.sol    → (eETH, weETH)
│   │   ├── NativeWrapperFrax.t.sol       → (frxETH, sfrxETH)
│   │   ├── NativeWrapperMantle.t.sol     → (mETH, cmETH)
│   │   ├── NativeWrapperOrigin.t.sol     → (OETH, WOETH)
│   │   ├── NativeWrapperPuffer.t.sol     → (pufETH)
│   │   └── NativeWrapperRenzo.t.sol      → (ezETH, pzETH)
│   ├── Permit2Forwarder.t.sol            → (Permit2 permits/transfers)
│   ├── V2Route.t.sol                     → (Uniswap V2 AMMs)
│   └── V3Route.t.sol                     → (Uniswap V3 AMMs)
├── shared/
│   ├── BaseTest.sol
│   ├── Constants.sol
│   ├── Permit2Utils.sol                  → Permit2 helpers
│   └── Planner.sol                       → Route builder DSL
├── types/
│   └── Stream.t.sol
└── RouteProcessor.t.sol
```

## Security Considerations

### Built-in Protections

-   **Reentrancy Guard** - All external entry points are protected
-   **Deadline Validation** - Transactions expire after specified timestamp
-   **Callback Authentication** - V3 callbacks use transient storage validation
-   **Slippage Protection** - Minimum output amounts enforced

### Known Considerations

-   The contract is stateless and does not hold user funds
-   All operations are atomic - entire transaction reverts on any failure
-   Native ETH handling requires careful recipient address validation
-   Permit2 integration requires users to approve Permit2 contract first

## Gas Optimization Techniques

-   **Inline Assembly** - Critical paths use hand-optimized assembly
-   **Transient Storage** - Callback validation uses `TSTORE`/`TLOAD` (EIP-1153)
-   **Packed Encoding** - Minimal calldata overhead with custom stream parser
-   **No Storage** - Stateless design eliminates SSTORE gas costs

## Resources

-   [Foundry Documentation](https://book.getfoundry.sh)
-   [Permit2 Documentation](https://docs.uniswap.org/contracts/permit2/overview)
-   [Uniswap V2 Documentation](https://docs.uniswap.org/contracts/v2/overview)
-   [Uniswap V3 Documentation](https://docs.uniswap.org/contracts/v3/overview)
-   [Curve Finance Documentation](https://docs.curve.finance/documentation-overview)

## Acknowledgments

Built with [Foundry](https://getfoundry.sh/) - A blazing fast, portable and modular toolkit for Ethereum application development.

Inspired by production routers from SushiSwap, Uniswap, and 1inch.

-   [RouteProcessor5](https://etherscan.io/address/0xf2614A233c7C3e7f08b1F887Ba133a13f1eb2c55)
-   [UniversalRouter](https://etherscan.io/address/0x66a9893cC07D91D95644AEDD05D03f95e1dBA8Af)
-   [AggregationRouterV6](https://etherscan.io/address/0x111111125421cA6dc452d289314280a0f8842A65)
