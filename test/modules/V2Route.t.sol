// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Errors} from "src/libraries/Errors.sol";
import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract V2RouteTest is BaseTest {
    using SafeTransferLib for address;

    uint24 internal constant UNI_V2_FEE = 3000;
    uint24 internal constant PANCAKE_V2_FEE = 2500;

    address internal constant UNI_V2_WBTC_WETH = 0xBb2b8038a1640196FbE3e38816F3e67Cba72D940;
    address internal constant UNI_V2_USDC_WETH = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;

    address internal constant PANCAKE_V2_WBTC_WETH = 0x4AB6702B3Ed3877e9b1f203f90cbEF13d663B0e8;
    address internal constant PANCAKE_V2_USDC_WETH = 0x2E8135bE71230c6B1B4045696d41C09Db0414226;

    address internal constant SLP_V2_WBTC_WETH = 0xCEfF51756c56CeFFCA006cD410B03FFC46dd3a58;
    address internal constant SLP_V2_SUSHI_WETH = 0x795065dCc9f64b5614C407a6EFDC400DA6221FB0;

    function test_processV2Swap_revertsWhenIdenticalTokens() public {
        plan = plan.addV2Swap(UNI_V2_USDC_WETH, WETH, UNI_V2_FEE);
        plan = plan.finalizeSwap(address(this), WETH, 1 ether, 1);

        vm.expectRevert(Errors.IdenticalAddresses.selector);
        rp.processRoute(plan.encode());
    }

    // WBTC -> WETH -> USDC on Uniswap V2
    function test_processV2SwapOnUniswapV2_multiHop() public {
        address tokenIn = WBTC;
        address tokenOut = USDC;

        deal(tokenIn, address(rp), 1e8);

        plan = plan.addV2Swap(UNI_V2_WBTC_WETH, WETH, UNI_V2_FEE);
        plan = plan.addV2Swap(UNI_V2_USDC_WETH, USDC, UNI_V2_FEE);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // WETH -> WBTC on Uniswap V2
    function test_processV2SwapOnUniswapV2_WETH_WBTC() public {
        address tokenIn = WETH;
        address tokenOut = WBTC;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addV2Swap(UNI_V2_WBTC_WETH, tokenOut, UNI_V2_FEE);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // WBTC -> WETH on Uniswap V2
    function test_processV2SwapOnUniswapV2_WBTC_WETH() public {
        address tokenIn = WBTC;
        address tokenOut = WETH;

        deal(tokenIn, address(rp), 1e8);

        plan = plan.addV2Swap(UNI_V2_WBTC_WETH, tokenOut, UNI_V2_FEE);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // WBTC -> WETH -> USDC on PancakeSwap V2
    function test_processV2SwapOnPancakeV2_multiHop() public {
        address tokenIn = WBTC;
        address tokenOut = USDC;

        deal(tokenIn, address(rp), 1e8);

        plan = plan.addV2Swap(PANCAKE_V2_WBTC_WETH, WETH, PANCAKE_V2_FEE);
        plan = plan.addV2Swap(PANCAKE_V2_USDC_WETH, USDC, PANCAKE_V2_FEE);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // WETH -> WBTC on PancakeSwap V2
    function test_processV2SwapOnPancakeV2_WETH_WBTC() public {
        address tokenIn = WETH;
        address tokenOut = WBTC;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addV2Swap(PANCAKE_V2_WBTC_WETH, tokenOut, PANCAKE_V2_FEE);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // WBTC -> WETH on PancakeSwap V2
    function test_processV2SwapOnPancakeV2_WBTC_WETH() public {
        address tokenIn = WBTC;
        address tokenOut = WETH;

        deal(tokenIn, address(rp), 1e8);

        plan = plan.addV2Swap(PANCAKE_V2_WBTC_WETH, tokenOut, PANCAKE_V2_FEE);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // WBTC -> WETH -> SUSHI on SushiSwap V2
    function test_processV2SwapOnSushiV2_multiHop() public {
        address tokenIn = WBTC;
        address tokenOut = SUSHI;

        deal(tokenIn, address(rp), 1e8);

        plan = plan.addV2Swap(SLP_V2_WBTC_WETH, WETH, UNI_V2_FEE);
        plan = plan.addV2Swap(SLP_V2_SUSHI_WETH, SUSHI, UNI_V2_FEE);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // WETH -> WBTC on SushiSwap V2
    function test_processV2SwapOnSushiV2_WETH_WBTC() public {
        address tokenIn = WETH;
        address tokenOut = WBTC;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addV2Swap(SLP_V2_WBTC_WETH, tokenOut, UNI_V2_FEE);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // WBTC -> WETH on SushiSwap V2
    function test_processV2SwapOnSushiV2_WBTC_WETH() public {
        address tokenIn = WBTC;
        address tokenOut = WETH;

        deal(tokenIn, address(rp), 1e8);

        plan = plan.addV2Swap(SLP_V2_WBTC_WETH, tokenOut, UNI_V2_FEE);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
