// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {AssetType, Protocol} from "src/types/Enums.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract NativeWrapperLidoTest is BaseTest {
    using SafeTransferLib for address;

    // ETH -> stETH
    function test_processNative_ETH_STETH() public {
        address tokenIn = ETH;
        address tokenOut = STETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        // plan = plan.addPath(Encoder.encodeLido(tokenIn, tokenOut));
        plan = plan.addWrap(Protocol.Lido, address(0), tokenOut, AssetType.ETH, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ETH -> wstETH
    function test_processNative_ETH_WSTETH() public {
        address tokenIn = ETH;
        address tokenOut = WSTETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        // plan = plan.addPath(Encoder.encodeLido(tokenIn, tokenOut));
        plan = plan.addWrap(Protocol.Lido, address(0), tokenOut, AssetType.ETH, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // stETH -> wstETH
    function test_processNative_STETH_WSTETH() public {
        address tokenIn = STETH;
        address tokenOut = WSTETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        // plan = plan.addPath(Encoder.encodeLido(tokenIn, tokenOut));
        plan = plan.addWrap(Protocol.Lido, address(0), tokenOut, AssetType.LST, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // wstETH -> stETH
    function test_processNative_WSTETH_STETH() public {
        address tokenIn = WSTETH;
        address tokenOut = STETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        // plan = plan.addPath(Encoder.encodeLido(tokenIn, tokenOut));
        plan = plan.addWrap(Protocol.Lido, address(0), tokenOut, AssetType.WLST, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
