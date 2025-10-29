// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {AssetType, Protocol} from "src/types/Enums.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract NativeWrapperPufferTest is BaseTest {
    using SafeTransferLib for address;

    // ETH -> pufETH
    function test_processNative_Puffer_ETH_PUFETH() public {
        address tokenIn = ETH;
        address tokenOut = PUFETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Puffer, address(0), tokenOut, AssetType.ETH, AssetType.LRT);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // WETH -> pufETH
    function test_processNative_Puffer_WETH_PUFETH() public {
        address tokenIn = WETH;
        address tokenOut = PUFETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Puffer, address(0), tokenOut, AssetType.WETH, AssetType.LRT);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // stETH -> pufETH
    function test_processNative_Puffer_STETH_PUFETH() public {
        address tokenIn = STETH;
        address tokenOut = PUFETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Puffer, address(0), tokenOut, AssetType.LST, AssetType.LRT);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // pufETH -> WETH
    function test_processNative_Puffer_PUFETH_WETH() public {
        address tokenIn = PUFETH;
        address tokenOut = WETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Puffer, address(0), tokenOut, AssetType.LRT, AssetType.WETH);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
