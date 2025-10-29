// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {AssetType, Protocol} from "src/types/Enums.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract NativeWrapperFraxTest is BaseTest {
    using SafeTransferLib for address;

    address internal constant FRXETH_MINTER = 0xbAFA44EFE7901E04E39Dad13167D089C559c1138;

    // ETH -> frxETH
    function test_processNative_Frax_ETH_FRXETH() public {
        address tokenIn = ETH;
        address tokenOut = FRXETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Frax, FRXETH_MINTER, tokenOut, AssetType.ETH, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ETH -> sfrxETH
    function test_processNative_Frax_ETH_SFRXETH() public {
        address tokenIn = ETH;
        address tokenOut = SFRXETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Frax, FRXETH_MINTER, tokenOut, AssetType.ETH, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // frxETH -> sfrxETH
    function test_processNative_Frax_FRXETH_SFRXETH() public {
        address tokenIn = FRXETH;
        address tokenOut = SFRXETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Frax, address(0), tokenOut, AssetType.LST, AssetType.WLST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // sfrxETH -> frxETH
    function test_processNative_Frax_SFRXETH_FRXETH() public {
        address tokenIn = SFRXETH;
        address tokenOut = FRXETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Frax, address(0), tokenOut, AssetType.WLST, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
