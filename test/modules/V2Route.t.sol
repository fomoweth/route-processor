// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Errors} from "src/libraries/Errors.sol";
import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {BaseTest} from "test/shared/BaseTest.sol";
import {Encoder} from "test/shared/Encoder.sol";

contract V2RouteTest is BaseTest {
    using SafeTransferLib for address;

    address internal constant UNI_V2_WBTC_WETH = 0xBb2b8038a1640196FbE3e38816F3e67Cba72D940;
    address internal constant UNI_V2_USDC_WETH = 0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc;

    address internal constant PANCAKE_V2_WBTC_WETH = 0x4AB6702B3Ed3877e9b1f203f90cbEF13d663B0e8;
    address internal constant PANCAKE_V2_USDC_WETH = 0x2E8135bE71230c6B1B4045696d41C09Db0414226;

    address internal constant SLP_V2_WBTC_WETH = 0xCEfF51756c56CeFFCA006cD410B03FFC46dd3a58;
    address internal constant SLP_V2_SUSHI_WETH = 0x795065dCc9f64b5614C407a6EFDC400DA6221FB0;

    function test_processV2Swap_revertsWhenIdenticalTokens() public {
        plan = plan.addPath(Encoder.encodeV2Swap(UNI_V2_USDC_WETH, WETH, UNI_V2_FEE));
        plan = plan.finalizeSwap(address(this), WETH, 1 ether, 0);

        vm.expectRevert(Errors.IdenticalAddresses.selector);
        rp.processRoute(plan.encode());
    }

    // WBTC -> WETH -> USDC on Uniswap V2
    function test_processV2Swap_multiHopForUniswapV2() public {
        deal(WBTC, address(rp), 1e8);
        plan = plan.addPath(Encoder.encodeV2Swap(UNI_V2_WBTC_WETH, WETH, UNI_V2_FEE));
        plan = plan.addPath(Encoder.encodeV2Swap(UNI_V2_USDC_WETH, USDC, UNI_V2_FEE));
        plan = plan.finalizeSwap(cooper.addr, WBTC, 1e8, 1);

        rp.processRoute(plan.encode());
        assertGt(USDC.balanceOf(cooper.addr), 0);
    }

    // WBTC <-> WETH on Uniswap V2
    function test_processV2Swap_singleHopForUniswapV2() public {
        testProcessV2Swap(UNI_V2_WBTC_WETH, WETH, WBTC, 10 ether, UNI_V2_FEE);
        testProcessV2Swap(UNI_V2_WBTC_WETH, WBTC, WETH, 1e8, UNI_V2_FEE);
    }

    // WBTC -> WETH -> USDC on PancakeSwap V2
    function test_processV2Swap_multiHopForPancakeV2() public {
        deal(WBTC, address(rp), 1e8);
        plan = plan.addPath(Encoder.encodeV2Swap(PANCAKE_V2_WBTC_WETH, WETH, PANCAKE_V2_FEE));
        plan = plan.addPath(Encoder.encodeV2Swap(PANCAKE_V2_USDC_WETH, USDC, PANCAKE_V2_FEE));
        plan = plan.finalizeSwap(cooper.addr, WBTC, 1e8, 1);

        rp.processRoute(plan.encode());
        assertGt(USDC.balanceOf(cooper.addr), 0);
    }

    // WBTC <-> WETH on PancakeSwap V2
    function test_processV2Swap_singleHopForPancakeV2() public {
        testProcessV2Swap(PANCAKE_V2_WBTC_WETH, WETH, WBTC, 10 ether, PANCAKE_V2_FEE);
        testProcessV2Swap(PANCAKE_V2_WBTC_WETH, WBTC, WETH, 1e8, PANCAKE_V2_FEE);
    }

    // WBTC -> WETH -> SUSHI on SushiSwap V2
    function test_processV2Swap_multiHopForSushiV2() public {
        deal(WBTC, address(rp), 1e8);
        plan = plan.addPath(Encoder.encodeV2Swap(SLP_V2_WBTC_WETH, WETH, UNI_V2_FEE));
        plan = plan.addPath(Encoder.encodeV2Swap(SLP_V2_SUSHI_WETH, SUSHI, UNI_V2_FEE));
        plan = plan.finalizeSwap(cooper.addr, WBTC, 1e8, 1);

        rp.processRoute(plan.encode());
        assertGt(SUSHI.balanceOf(cooper.addr), 0);
    }

    // WBTC <-> WETH on SushiSwap V2
    function test_processV2Swap_singleHopForSushiV2() public {
        testProcessV2Swap(SLP_V2_WBTC_WETH, WETH, WBTC, 10 ether, UNI_V2_FEE);
        testProcessV2Swap(SLP_V2_WBTC_WETH, WBTC, WETH, 1e8, UNI_V2_FEE);
    }

    function testProcessV2Swap(address pool, address tokenIn, address tokenOut, uint256 amountIn, uint24 fee)
        internal
    {
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addPath(Encoder.encodeV2Swap(pool, tokenOut, fee));
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        bytes memory route = plan.encode();
        rp.processRoute(route);

        assertGt(tokenOut.balanceOf(cooper.addr), 0);
        revertToState();
    }
}
