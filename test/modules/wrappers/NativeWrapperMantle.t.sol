// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {AssetType, Protocol} from "src/types/Enums.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract NativeWrapperMantleTest is BaseTest {
    using SafeTransferLib for address;

    // ETH -> mETH
    function test_processNative_Mantle_ETH_METH() public {
        address tokenIn = ETH;
        address tokenOut = METH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addWrap(Protocol.Mantle, METH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ETH -> cmETH
    function test_processNative_Mantle_ETH_CMETH() public {
        address tokenIn = ETH;
        address tokenOut = CMETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addWrap(Protocol.Mantle, CMETH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.LRT);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // mETH -> cmETH
    function test_processNative_Mantle_METH_CMETH() public {
        address tokenIn = METH;
        address tokenOut = CMETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addWrap(Protocol.Mantle, CMETH_DEPOSIT, tokenOut, AssetType.LST, AssetType.LRT);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
