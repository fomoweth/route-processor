// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {AssetType, Protocol} from "src/types/Enums.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract NativeWrapperRenzoTest is BaseTest {
    using SafeTransferLib for address;

    // ETH -> ezETH
    function test_processNative_Renzo_ETH_EZETH() public {
        address tokenIn = ETH;
        address tokenOut = EZETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addWrap(Protocol.Renzo, EZETH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.LRT);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // stETH -> ezETH
    function test_processNative_Renzo_STETH_EZETH() public {
        address tokenIn = STETH;
        address tokenOut = EZETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addWrap(Protocol.Renzo, EZETH_DEPOSIT, tokenOut, AssetType.LST, AssetType.LRT);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // wstETH -> pzETH
    function test_processNative_Renzo_WSTETH_PZETH() public {
        address tokenIn = WSTETH;
        address tokenOut = PZETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addWrap(Protocol.Renzo, address(0), tokenOut, AssetType.WLST, AssetType.LRT);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
