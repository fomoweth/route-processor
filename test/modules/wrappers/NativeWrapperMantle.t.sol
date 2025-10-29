// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {AssetType, Protocol} from "src/types/Enums.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract NativeWrapperMantleTest is BaseTest {
    using SafeTransferLib for address;

    address internal constant STAKING = 0xe3cBd06D7dadB3F4e6557bAb7EdD924CD1489E8f;
    address internal constant TELLER = 0xB6f7D38e3EAbB8f69210AFc2212fe82e0f1912b0;

    // ETH -> mETH
    function test_processNative_Mantle_ETH_METH() public {
        address tokenIn = ETH;
        address tokenOut = METH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Mantle, STAKING, tokenOut, AssetType.ETH, AssetType.LST);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // ETH -> cmETH
    function test_processNative_Mantle_ETH_CMETH() public {
        address tokenIn = ETH;
        address tokenOut = CMETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Mantle, TELLER, tokenOut, AssetType.ETH, AssetType.LRT);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // mETH -> cmETH
    function test_processNative_Mantle_METH_CMETH() public {
        address tokenIn = METH;
        address tokenOut = CMETH;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addWrap(Protocol.Mantle, TELLER, tokenOut, AssetType.LST, AssetType.LRT);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
