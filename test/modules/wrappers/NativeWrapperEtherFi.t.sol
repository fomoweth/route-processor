// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {AssetType, Protocol} from "src/types/Enums.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract NativeWrapperEtherFiTest is BaseTest {
    using SafeTransferLib for address;

    // ETH -> eETH
    function test_processNative_EtherFi_ETH_EETH() public {
        address tokenIn = ETH;
        address tokenOut = EETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addWrap(Protocol.EtherFi, EETH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ETH -> weETH
    function test_processNative_EtherFi_ETH_WEETH() public {
        address tokenIn = ETH;
        address tokenOut = WEETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addWrap(Protocol.EtherFi, EETH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // eETH -> weETH
    function test_processNative_EtherFi_EETH_WEETH() public {
        address tokenIn = EETH;
        address tokenOut = WEETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addWrap(Protocol.EtherFi, address(0), tokenOut, AssetType.LST, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // weETH -> eETH
    function test_processNative_EtherFi_WEETH_EETH() public {
        address tokenIn = WEETH;
        address tokenOut = EETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addWrap(Protocol.EtherFi, address(0), tokenOut, AssetType.WLST, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
