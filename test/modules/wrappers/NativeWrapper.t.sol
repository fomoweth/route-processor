// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {AssetType, Protocol} from "src/types/Enums.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract NativeWrapperTest is BaseTest {
    using SafeTransferLib for address;

    address internal constant ROCKET_DEPOSIT_POOL = 0xDD3f50F8A6CafbE9b31a427582963f465E745AF8;
    address internal constant STADER_STAKE_POOL = 0xcf5EA1b38380f6aF39068375516Daf40Ed70D299;
    address internal constant ETH_GENESIS_VAULT = 0xAC0F906E433d58FA868F936E8A43230473652885;

    // ETH -> WETH
    function test_processNative_ETH_WETH() public {
        address tokenIn = ETH;
        address tokenOut = WETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.WETH, address(0), tokenOut, AssetType.ETH, AssetType.WETH);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // WETH -> ETH
    function test_processNative_WETH_ETH() public {
        address tokenIn = WETH;
        address tokenOut = ETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.WETH, address(0), tokenOut, AssetType.WETH, AssetType.ETH);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ETH -> rETH
    function test_processNative_Rocket_ETH_RETH() public {
        address tokenIn = ETH;
        address tokenOut = RETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Rocket, ROCKET_DEPOSIT_POOL, tokenOut, AssetType.ETH, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ETH -> swETH
    function test_processNative_Swell_ETH_SWETH() public {
        address tokenIn = ETH;
        address tokenOut = SWETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Swell, address(0), tokenOut, AssetType.ETH, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ETH -> wBETH
    function test_processNative_Binance_ETH_WBETH() public {
        address tokenIn = ETH;
        address tokenOut = WBETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Binance, address(0), tokenOut, AssetType.ETH, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ETH -> ETHx
    function test_processNative_Stader_ETH_ETHx() public {
        address tokenIn = ETH;
        address tokenOut = ETHX;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Stader, STADER_STAKE_POOL, tokenOut, AssetType.ETH, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ETH -> osETH
    function test_processNative_StakeWise_ETH_OSETH() public {
        address tokenIn = ETH;
        address tokenOut = OSETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.StakeWise, ETH_GENESIS_VAULT, tokenOut, AssetType.ETH, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
