// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract CurveRouteStablePoolTest is BaseTest {
    using SafeTransferLib for address;

    address internal constant STETH_POOL = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022; // ETH/stETH
    address internal constant FRXETH_POOL = 0x9c3B46C0Ceb5B9e304FCd6D88Fc50f7DD24B31Bc; // WETH/frxETH
    address internal constant STETH_FRXETH_POOL = 0x4d9f9D15101EEC665F77210cB999639f760F831E; // stETH/frxETH
    address internal constant WEETH_POOL = 0xDB74dfDD3BB46bE8Ce6C33dC9D82777BCFc3dEd5; // WETH/weETH
    address internal constant RETH_POOL = 0x9EfE1A1Cbd6Ca51Ee8319AFc4573d253C3B732af; // WETH/rETH

    /// @dev Executes a multi-hop curve route: ETH → stETH → frxETH → WETH
    function test_processCurveOnStablePool_multiHop_ETH_STETH_FRXETH_WETH() public {
        address tokenIn = ETH;
        address tokenOut = WETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addCurve(STETH_POOL, STETH, 0, 1, false, false, false);
        plan = plan.addCurve(STETH_FRXETH_POOL, FRXETH, 0, 1, false, false, false);
        plan = plan.addCurve(FRXETH_POOL, WETH, 1, 0, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnStablePool_ETH_STETH() public {
        address tokenIn = ETH;
        address tokenOut = STETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addCurve(STETH_POOL, tokenOut, 0, 1, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnStablePool_STETH_ETH() public {
        address tokenIn = STETH;
        address tokenOut = ETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addCurve(STETH_POOL, tokenOut, 1, 0, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnStablePool_WETH_FRXETH() public {
        address tokenIn = WETH;
        address tokenOut = FRXETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addCurve(FRXETH_POOL, tokenOut, 0, 1, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnStablePool_FRXETH_WETH() public {
        address tokenIn = FRXETH;
        address tokenOut = WETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addCurve(FRXETH_POOL, tokenOut, 1, 0, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnStablePool_WETH_WEETH() public {
        address tokenIn = WETH;
        address tokenOut = WEETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addCurve(WEETH_POOL, tokenOut, 0, 1, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnStablePool_WEETH_WETH() public {
        address tokenIn = WEETH;
        address tokenOut = WETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addCurve(WEETH_POOL, tokenOut, 1, 0, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnStablePool_WETH_RETH() public {
        address tokenIn = WETH;
        address tokenOut = RETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addCurve(RETH_POOL, tokenOut, 0, 1, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnStablePool_RETH_WETH() public {
        address tokenIn = RETH;
        address tokenOut = WETH;
        uint256 amountIn = 10 ether;
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addCurve(RETH_POOL, tokenOut, 1, 0, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
