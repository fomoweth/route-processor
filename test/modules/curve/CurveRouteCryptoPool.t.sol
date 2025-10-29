// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract CurveRouteCryptoPoolTest is BaseTest {
    using SafeTransferLib for address;

    address internal constant TRICRYPTO = 0xD51a44d3FaE010294C616388b506AcdA1bfAAE46; // USDT/WBTC/WETH

    function test_processCurveOnCryptoPool_USDT_WBTC() public {
        address tokenIn = USDT;
        address tokenOut = WBTC;

        deal(tokenIn, address(rp), 100000e6);

        plan = plan.addCurve(TRICRYPTO, tokenOut, 0, 1, true, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnCryptoPool_USDT_WETH() public {
        address tokenIn = USDT;
        address tokenOut = WETH;

        deal(tokenIn, address(rp), 100000e6);

        plan = plan.addCurve(TRICRYPTO, tokenOut, 0, 2, true, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnCryptoPool_WBTC_USDT() public {
        address tokenIn = WBTC;
        address tokenOut = USDT;

        deal(tokenIn, address(rp), 1e8);

        plan = plan.addCurve(TRICRYPTO, tokenOut, 1, 0, true, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnCryptoPool_WBTC_WETH() public {
        address tokenIn = WBTC;
        address tokenOut = WETH;

        deal(tokenIn, address(rp), 1e8);

        plan = plan.addCurve(TRICRYPTO, tokenOut, 1, 2, true, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnCryptoPool_WETH_USDT() public {
        address tokenIn = WETH;
        address tokenOut = USDT;

        deal(tokenIn, address(rp), 20 ether);

        plan = plan.addCurve(TRICRYPTO, tokenOut, 2, 0, true, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnCryptoPool_WETH_WBTC() public {
        address tokenIn = WETH;
        address tokenOut = WBTC;

        deal(tokenIn, address(rp), 20 ether);

        plan = plan.addCurve(TRICRYPTO, tokenOut, 2, 1, true, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnCryptoPool_ETH_USDT_useEth() public {
        address tokenIn = ETH;
        address tokenOut = USDT;

        deal(tokenIn, address(rp), 20 ether);

        plan = plan.addCurve(TRICRYPTO, tokenOut, 2, 0, true, false, true);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnCryptoPool_ETH_WBTC_useEth() public {
        address tokenIn = ETH;
        address tokenOut = WBTC;

        deal(tokenIn, address(rp), 20 ether);

        plan = plan.addCurve(TRICRYPTO, tokenOut, 2, 1, true, false, true);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
