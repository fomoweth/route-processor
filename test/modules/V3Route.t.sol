// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Errors} from "src/libraries/Errors.sol";
import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract V3RouteTest is BaseTest {
    using SafeTransferLib for address;

    bytes4 internal constant UNISWAP_V3_SWAP_CALLBACK = 0xfa461e33; // uniswapV3SwapCallback(int256,int256,bytes)
    bytes4 internal constant PANCAKE_V3_SWAP_CALLBACK = 0x23a69e75; // pancakeV3SwapCallback(int256,int256,bytes)

    address internal constant UNI_V3_USDC_WETH = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640; // 0.05%
    address internal constant UNI_V3_WETH_USDT = 0x4e68Ccd3E89f51C3074ca5072bbAC773960dFa36; // 0.3%

    address internal constant PANCAKE_V3_USDC_WETH = 0x1ac1A8FEaAEa1900C4166dEeed0C11cC10669D36; // 0.05%
    address internal constant PANCAKE_V3_WETH_USDT = 0x6CA298D2983aB03Aa1dA7679389D955A4eFEE15C; // 0.05%

    address internal constant SLP_V3_SUSHI_WETH = 0x87C7056BBE6084f03304196Be51c6B90B6d85Aa2; // 0.3%

    function test_processV3Swap_revertsWhenIdenticalTokens() public {
        plan = plan.addV3Swap(UNI_V3_USDC_WETH, WETH, UNISWAP_V3_SWAP_CALLBACK);
        plan = plan.finalizeSwap(address(this), WETH, 1 ether, 0);

        vm.expectRevert(Errors.IdenticalAddresses.selector);
        rp.processRoute(plan.encode());
    }

    // USDC -> WETH -> USDT on Uniswap V3
    function test_processV3SwapOnUniswapV3_multiHop() public {
        address tokenIn = USDC;
        address tokenOut = USDT;

        deal(tokenIn, address(rp), 10000e6);

        plan = plan.addV3Swap(UNI_V3_USDC_WETH, WETH, UNISWAP_V3_SWAP_CALLBACK);
        plan = plan.addV3Swap(UNI_V3_WETH_USDT, USDT, UNISWAP_V3_SWAP_CALLBACK);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // USDC -> WETH -> USDT on PancakeSwap V3
    function test_processV3SwapOnPancakeV3_multiHop() public {
        address tokenIn = USDC;
        address tokenOut = USDT;

        deal(tokenIn, address(rp), 10000e6);

        plan = plan.addV3Swap(PANCAKE_V3_USDC_WETH, WETH, PANCAKE_V3_SWAP_CALLBACK);
        plan = plan.addV3Swap(PANCAKE_V3_WETH_USDT, USDT, PANCAKE_V3_SWAP_CALLBACK);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // WETH -> USDC on Uniswap V3
    function test_processV3SwapOnUniswapV3_WETH_USDC() public {
        address tokenIn = WETH;
        address tokenOut = USDC;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addV3Swap(UNI_V3_USDC_WETH, tokenOut, UNISWAP_V3_SWAP_CALLBACK);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // USDC -> WETH on Uniswap V3
    function test_processV3SwapOnUniswapV3_USDC_WETH() public {
        address tokenIn = USDC;
        address tokenOut = WETH;

        deal(tokenIn, address(rp), 40000e6);

        plan = plan.addV3Swap(UNI_V3_USDC_WETH, tokenOut, UNISWAP_V3_SWAP_CALLBACK);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // WETH -> USDC on PancakeSwap V3
    function test_processV3SwapOnPancakeV3_WETH_USDC() public {
        address tokenIn = WETH;
        address tokenOut = USDC;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addV3Swap(PANCAKE_V3_USDC_WETH, tokenOut, PANCAKE_V3_SWAP_CALLBACK);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // USDC -> WETH on PancakeSwap V3
    function test_processV3SwapOnPancakeV3_USDC_WETH() public {
        address tokenIn = USDC;
        address tokenOut = WETH;

        deal(tokenIn, address(rp), 40000e6);

        plan = plan.addV3Swap(PANCAKE_V3_USDC_WETH, tokenOut, PANCAKE_V3_SWAP_CALLBACK);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // WETH -> SUSHI on SushiSwap V3
    function test_processV3SwapOnSushiV3_WETH_SUSHI() public {
        address tokenIn = WETH;
        address tokenOut = SUSHI;

        deal(tokenIn, address(rp), 10 ether);

        plan = plan.addV3Swap(SLP_V3_SUSHI_WETH, tokenOut, UNISWAP_V3_SWAP_CALLBACK);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    // SUSHI -> WETH on SushiSwap V3
    function test_processV3SwapOnSushiV3_SUSHI_WETH() public {
        address tokenIn = SUSHI;
        address tokenOut = WETH;

        deal(tokenIn, address(rp), 50000 ether);

        plan = plan.addV3Swap(SLP_V3_SUSHI_WETH, tokenOut, UNISWAP_V3_SWAP_CALLBACK);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }
}
