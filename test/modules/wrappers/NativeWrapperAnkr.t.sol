// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {AssetType, Protocol} from "src/types/Enums.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract NativeWrapperAnkrTest is BaseTest {
    using SafeTransferLib for address;

    address internal constant GLOBAL_POOL_R46 = 0x84db6eE82b7Cf3b47E8F19270abdE5718B936670;

    // ETH -> ankrETH
    function test_processNative_Ankr_ETH_AnkrETH() public {
        address tokenIn = ETH;
        address tokenOut = ANKRETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Ankr, GLOBAL_POOL_R46, tokenOut, AssetType.ETH, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ETH -> aETHb
    function test_processNative_Ankr_ETH_AETHb() public {
        address tokenIn = ETH;
        address tokenOut = AETHB;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Ankr, GLOBAL_POOL_R46, tokenOut, AssetType.ETH, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ankrETH -> aETHb
    function test_processNative_Ankr_AnkrETH_AETHb() public {
        address tokenIn = ANKRETH;
        address tokenOut = AETHB;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Ankr, address(0), tokenOut, AssetType.LST, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // aETHb -> ankrETH
    function test_processNative_Ankr_AETHb_AnkrETH() public {
        address tokenIn = AETHB;
        address tokenOut = ANKRETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Ankr, address(0), tokenOut, AssetType.WLST, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
