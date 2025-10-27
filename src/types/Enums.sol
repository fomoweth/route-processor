// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title Protocol
/// @notice Identifiers for supported DeFi and LST protocols handled by the RouteProcessor.
/// @dev Used in packed route encoding and protocol dispatch within modules like LSTForwarder, V2Route, V3Route, and CurveRoute.
enum Protocol {
    WETH, // Wrapped Ether (Base ERC20 equivalent of ETH)
    Curve, // Curve AMM pools (including crypto and underlying pools)
    UniswapV2, // Uniswap V2-style pools
    UniswapV3, // Uniswap V3-style pools
    Rocket, // Rocket Pool (rETH)
    Swell, // Swell Network (swETH)
    Binance, // Binance Staking (wBETH)
    Stader, // Stader Labs (ETHx)
    StakeWise, // StakeWise V3 (osETH)
    Lido, // Lido Finance (stETH, wstETH)
    EtherFi, // Ether.Fi (eETH, weETH)
    Frax, // Frax Ether (frxETH, sfrxETH)
    Origin, // Origin Ether (oETH, woETH)
    Ankr, // Ankr Staking (ankrETH, aETHb)
    Mantle, // Mantle Staked ETH (mETH, cmETH)
    Renzo, // Renzo Protocol (ezETH, pzETH)
    Puffer // Puffer Finance (pufETH)

}

/// @title AssetType
/// @notice Categorizes ETH and its derivative token types for LST and LRT ecosystems.
/// @dev Used for operation encoding, decoding, and asset flow analysis within the router.
enum AssetType {
    ETH, // Native Ether
    WETH, // Wrapped Ether
    // Liquid Staking Tokens (LST)
    // Examples: rETH, swETH, wBETH, ETHx, osETH, stETH, eETH, frxETH, oETH, ankrETH, mETH
    LST,
    // Wrapped Liquid Staking Tokens (WLST)
    // Examples: wstETH, weETH, sfrxETH, woETH, aETHb
    WLST,
    // Liquid Restaking Tokens (LRT)
    // Examples: cmETH, ezETH, pzETH, pufETH
    LRT
}
