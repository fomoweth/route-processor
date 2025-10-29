// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {AssetType, Protocol} from "src/types/Enums.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract NativeWrapperEtherFiTest is BaseTest {
    using SafeTransferLib for address;

    address internal constant LIQUIDITY_POOL = 0x308861A430be4cce5502d0A12724771Fc6DaF216;

    // ETH -> eETH
    function test_processNative_EtherFi_ETH_EETH() public {
        address tokenIn = ETH;
        address tokenOut = EETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.EtherFi, LIQUIDITY_POOL, tokenOut, AssetType.ETH, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ETH -> weETH
    function test_processNative_EtherFi_ETH_WEETH() public {
        address tokenIn = ETH;
        address tokenOut = WEETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.EtherFi, LIQUIDITY_POOL, tokenOut, AssetType.ETH, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // eETH -> weETH
    function test_processNative_EtherFi_EETH_WEETH() public {
        address tokenIn = EETH;
        address tokenOut = WEETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.EtherFi, address(0), tokenOut, AssetType.LST, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // weETH -> eETH
    function test_processNative_EtherFi_WEETH_EETH() public {
        address tokenIn = WEETH;
        address tokenOut = EETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.EtherFi, address(0), tokenOut, AssetType.WLST, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
