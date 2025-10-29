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

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Lido, address(0), tokenOut, AssetType.ETH, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ETH -> wstETH
    function test_processNative_ETH_WSTETH() public {
        address tokenIn = ETH;
        address tokenOut = WSTETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Lido, address(0), tokenOut, AssetType.ETH, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // stETH -> wstETH
    function test_processNative_STETH_WSTETH() public {
        address tokenIn = STETH;
        address tokenOut = WSTETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Lido, address(0), tokenOut, AssetType.LST, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // wstETH -> stETH
    function test_processNative_WSTETH_STETH() public {
        address tokenIn = WSTETH;
        address tokenOut = STETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Lido, address(0), tokenOut, AssetType.WLST, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
