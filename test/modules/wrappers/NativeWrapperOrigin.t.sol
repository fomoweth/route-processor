// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {AssetType, Protocol} from "src/types/Enums.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract NativeWrapperOriginTest is BaseTest {
    using SafeTransferLib for address;

    // ETH -> OETH
    function test_processNative_Origin_WETH_OETH() public {
        address tokenIn = WETH;
        address tokenOut = OETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addWrap(Protocol.Origin, OETH_DEPOSIT, tokenOut, AssetType.WETH, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ETH -> WOETH
    function test_processNative_Origin_WETH_WOETH() public {
        address tokenIn = WETH;
        address tokenOut = WOETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addWrap(Protocol.Origin, OETH_DEPOSIT, tokenOut, AssetType.WETH, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // OETH -> WOETH
    function test_processNative_Origin_OETH_WOETH() public {
        address tokenIn = OETH;
        address tokenOut = WOETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addWrap(Protocol.Origin, address(0), tokenOut, AssetType.LST, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // WOETH -> OETH
    function test_processNative_Origin_WOETH_OETH() public {
        address tokenIn = WOETH;
        address tokenOut = OETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addWrap(Protocol.Origin, address(0), tokenOut, AssetType.WLST, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
