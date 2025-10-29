// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract CurveRouteMetaPoolTest is BaseTest {
    using SafeTransferLib for address;

    address internal constant FRAX_2POOL_LP = 0x3175Df0976dFA876431C2E9eE6Bc45b65d3473CC; // crvFRAX
    address internal constant FRAX_2POOL = 0xDcEF968d416a41Cdac0ED8702fAC8128A64241A2; // FRAX/USDC

    address internal constant CRV_3POOL_LP = 0x6c3F90f043a72FA612cbac8115EE7e52BDe6E490;
    address internal constant CRV_3POOL = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7; // DAI/USDC/USDT

    address internal constant FRAX_3POOL = 0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B; // FRAX/3CRV

    function test_processCurveOnMetaPool_multiHop_FRAX_USDC_DAI() public {
        address tokenIn = FRAX;
        address tokenOut = FRAX;

        deal(tokenIn, address(rp), 10000 ether);

        plan = plan.addCurve(FRAX_2POOL, USDC, 0, 1, false, false, false);
        plan = plan.addCurve(CRV_3POOL, DAI, 1, 0, false, false, false);
        plan = plan.addCurve(FRAX_3POOL, FRAX, 1, 0, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnMetaPool_FRAX_3CRV() public {
        address tokenIn = FRAX;
        address tokenOut = CRV_3POOL_LP;

        deal(tokenIn, address(rp), 10000 ether);

        plan = plan.addCurve(FRAX_3POOL, tokenOut, 0, 1, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnMetaPool_3CRV_FRAX() public {
        address tokenIn = CRV_3POOL_LP;
        address tokenOut = FRAX;

        deal(tokenIn, address(rp), 10000 ether);

        plan = plan.addCurve(FRAX_3POOL, tokenOut, 1, 0, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnMetaPool_FRAX_DAI() public {
        address tokenIn = FRAX;
        address tokenOut = DAI;

        deal(tokenIn, address(rp), 10000 ether);

        plan = plan.addCurve(FRAX_3POOL, tokenOut, 0, 1, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnMetaPool_FRAX_USDC() public {
        address tokenIn = FRAX;
        address tokenOut = USDC;

        deal(tokenIn, address(rp), 10000 ether);

        plan = plan.addCurve(FRAX_3POOL, tokenOut, 0, 2, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnMetaPool_FRAX_USDT() public {
        address tokenIn = FRAX;
        address tokenOut = USDT;

        deal(tokenIn, address(rp), 10000 ether);

        plan = plan.addCurve(FRAX_3POOL, tokenOut, 0, 3, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnMetaPool_DAI_FRAX() public {
        address tokenIn = DAI;
        address tokenOut = FRAX;

        deal(tokenIn, address(rp), 10000 ether);

        plan = plan.addCurve(FRAX_3POOL, tokenOut, 1, 0, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnMetaPool_DAI_USDC() public {
        address tokenIn = DAI;
        address tokenOut = USDC;

        deal(tokenIn, address(rp), 10000 ether);

        plan = plan.addCurve(FRAX_3POOL, tokenOut, 1, 2, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnMetaPool_DAI_USDT() public {
        address tokenIn = DAI;
        address tokenOut = USDT;

        deal(tokenIn, address(rp), 10000 ether);

        plan = plan.addCurve(FRAX_3POOL, tokenOut, 1, 3, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnMetaPool_USDC_FRAX() public {
        address tokenIn = USDC;
        address tokenOut = FRAX;

        deal(tokenIn, address(rp), 10000e6);

        plan = plan.addCurve(FRAX_3POOL, tokenOut, 2, 0, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnMetaPool_USDC_DAI() public {
        address tokenIn = USDC;
        address tokenOut = DAI;

        deal(tokenIn, address(rp), 10000e6);

        plan = plan.addCurve(FRAX_3POOL, tokenOut, 2, 1, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnMetaPool_USDC_USDT() public {
        address tokenIn = USDC;
        address tokenOut = USDT;

        deal(tokenIn, address(rp), 10000e6);

        plan = plan.addCurve(FRAX_3POOL, tokenOut, 2, 3, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnMetaPool_USDT_FRAX() public {
        address tokenIn = USDT;
        address tokenOut = FRAX;

        deal(tokenIn, address(rp), 10000e6);

        plan = plan.addCurve(FRAX_3POOL, tokenOut, 3, 0, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnMetaPool_USDT_DAI() public {
        address tokenIn = USDT;
        address tokenOut = DAI;

        deal(tokenIn, address(rp), 10000e6);

        plan = plan.addCurve(FRAX_3POOL, tokenOut, 3, 1, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnMetaPool_USDT_USDC() public {
        address tokenIn = USDT;
        address tokenOut = USDC;

        deal(tokenIn, address(rp), 10000e6);

        plan = plan.addCurve(FRAX_3POOL, tokenOut, 3, 2, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
