// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IPermit2} from "permit2/interfaces/IPermit2.sol";

abstract contract Constants {
    IPermit2 internal constant PERMIT2 = IPermit2(0x000000000022D473030F116dDEE9F6B43aC78BA3);

    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address internal constant RETH = 0xae78736Cd615f374D3085123A210448E74Fc6393;
    address internal constant SWETH = 0xf951E335afb289353dc249e82926178EaC7DEd78;
    address internal constant WBETH = 0xa2E3356610840701BDf5611a53974510Ae27E2e1;
    address internal constant ETHX = 0xA35b1B31Ce002FBF2058D22F30f95D405200A15b;
    address internal constant OSETH = 0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38;
    address internal constant STETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address internal constant WSTETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;
    address internal constant EETH = 0x35fA164735182de50811E8e2E824cFb9B6118ac2;
    address internal constant WEETH = 0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee;
    address internal constant FRXETH = 0x5E8422345238F34275888049021821E8E08CAa1f;
    address internal constant SFRXETH = 0xac3E018457B222d93114458476f3E3416Abbe38F;
    address internal constant OETH = 0x856c4Efb76C1D1AE02e20CEB03A2A6a08b0b8dC3;
    address internal constant WOETH = 0xDcEe70654261AF21C44c093C300eD3Bb97b78192;
    address internal constant ANKRETH = 0xE95A203B1a91a908F9B9CE46459d101078c2c3cb;
    address internal constant AETHB = 0xD01ef7C0A5d8c432fc2d1a85c66cF2327362E5C6;
    address internal constant METH = 0xd5F7838F5C461fefF7FE49ea5ebaF7728bB0ADfa;
    address internal constant CMETH = 0xE6829d9a7eE3040e1276Fa75293Bde931859e8fA;
    address internal constant EZETH = 0xbf5495Efe5DB9ce00f80364C8B423567e58d2110;
    address internal constant PZETH = 0x8c9532a60E0E7C6BbD2B2c1303F63aCE1c3E9811;
    address internal constant PUFETH = 0xD9A442856C234a39a81a089C06451EBAa4306a72;

    address internal constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address internal constant FRAX = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
    address internal constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address internal constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address internal constant SUSHI = 0x6B3595068778DD592e39A122f4f5a5cF09C90fE2;

    uint256 internal constant FORK_BLOCK = 23671796;

    uint256 internal constant CONTRACT_BALANCE = 0x8000000000000000000000000000000000000000000000000000000000000000;

    uint256 internal constant MAX_UINT256 = type(uint256).max;
    uint160 internal constant MAX_UINT160 = type(uint160).max;
    uint128 internal constant MAX_UINT128 = type(uint128).max;
    uint48 internal constant MAX_UINT48 = type(uint48).max;

    // 0xfa461e33: uniswapV3SwapCallback(int256,int256,bytes)
    bytes4 internal constant UNISWAP_V3_SWAP_CALLBACK = 0xfa461e33;
    // 0x23a69e75: pancakeV3SwapCallback(int256,int256,bytes)
    bytes4 internal constant PANCAKE_V3_SWAP_CALLBACK = 0x23a69e75;

    uint24 internal constant UNI_V2_FEE = 3000;
    uint24 internal constant PANCAKE_V2_FEE = 2500;
}
