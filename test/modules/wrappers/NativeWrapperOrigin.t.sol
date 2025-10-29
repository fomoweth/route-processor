// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {AssetType, Protocol} from "src/types/Enums.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract NativeWrapperOriginTest is BaseTest {
    using SafeTransferLib for address;

    address internal constant OETH_VAULT = 0x39254033945AA2E4809Cc2977E7087BEE48bd7Ab;

    // ETH -> OETH
    function test_processNative_Origin_WETH_OETH() public {
        address tokenIn = WETH;
        address tokenOut = OETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Origin, OETH_VAULT, tokenOut, AssetType.WETH, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ETH -> WOETH
    function test_processNative_Origin_WETH_WOETH() public {
        address tokenIn = WETH;
        address tokenOut = WOETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Origin, OETH_VAULT, tokenOut, AssetType.WETH, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // OETH -> WOETH
    function test_processNative_Origin_OETH_WOETH() public {
        address tokenIn = OETH;
        address tokenOut = WOETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Origin, address(0), tokenOut, AssetType.LST, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // WOETH -> OETH
    function test_processNative_Origin_WOETH_OETH() public {
        address tokenIn = WOETH;
        address tokenOut = OETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Origin, address(0), tokenOut, AssetType.WLST, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
