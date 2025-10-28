// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Errors} from "src/libraries/Errors.sol";
import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {BaseTest} from "test/shared/BaseTest.sol";
import {Encoder} from "test/shared/Encoder.sol";

contract V3RouteTest is BaseTest {
    using SafeTransferLib for address;

    address internal constant UNI_V3_USDC_WETH = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640; // 0.05%
    address internal constant UNI_V3_WETH_USDT = 0x4e68Ccd3E89f51C3074ca5072bbAC773960dFa36; // 0.3%

    address internal constant PANCAKE_V3_USDC_WETH = 0x1ac1A8FEaAEa1900C4166dEeed0C11cC10669D36; // 0.05%
    address internal constant PANCAKE_V3_WETH_USDT = 0x6CA298D2983aB03Aa1dA7679389D955A4eFEE15C; // 0.05%

    address internal constant SLP_V3_SUSHI_WETH = 0x87C7056BBE6084f03304196Be51c6B90B6d85Aa2; // 0.3%

    function test_processV3Swap_revertsWhenIdenticalTokens() public {
        plan = plan.addPath(Encoder.encodeV3Swap(UNI_V3_USDC_WETH, WETH, UNISWAP_V3_SWAP_CALLBACK));
        plan = plan.finalizeSwap(address(this), WETH, 1 ether, 0);

        vm.expectRevert(Errors.IdenticalAddresses.selector);
        rp.processRoute(plan.encode());
    }

    // USDC -> WETH -> USDT on Uniswap V3
    function test_processV3Swap_multiHopForUniswapV3() public {
        deal(USDC, address(rp), 10000e6);
        plan = plan.addPath(Encoder.encodeV3Swap(UNI_V3_USDC_WETH, WETH, UNISWAP_V3_SWAP_CALLBACK));
        plan = plan.addPath(Encoder.encodeV3Swap(UNI_V3_WETH_USDT, USDT, UNISWAP_V3_SWAP_CALLBACK));
        plan = plan.finalizeSwap(cooper.addr, USDC, 10000e6, 1);

        rp.processRoute(plan.encode());
        assertGt(USDT.balanceOf(cooper.addr), 0);
    }

    // USDC -> WETH -> USDT on PancakeSwap V3
    function test_processV3Swap_multiHopForPancakeV3() public {
        deal(USDC, address(rp), 10000e6);
        plan = plan.addPath(Encoder.encodeV3Swap(PANCAKE_V3_USDC_WETH, WETH, PANCAKE_V3_SWAP_CALLBACK));
        plan = plan.addPath(Encoder.encodeV3Swap(PANCAKE_V3_WETH_USDT, USDT, PANCAKE_V3_SWAP_CALLBACK));
        plan = plan.finalizeSwap(cooper.addr, USDC, 10000e6, 1);

        rp.processRoute(plan.encode());
        assertGt(USDT.balanceOf(cooper.addr), 0);
    }

    // USDC <-> WETH on Uniswap V3
    function test_processV3Swap_singleHopForUniswapV3() public {
        testProcessV3Swap(UNI_V3_USDC_WETH, WETH, USDC, 10 ether, UNISWAP_V3_SWAP_CALLBACK);
        testProcessV3Swap(UNI_V3_USDC_WETH, USDC, WETH, 40000e6, UNISWAP_V3_SWAP_CALLBACK);
    }

    // USDC <-> WETH on PancakeSwap V3
    function test_processV3Swap_singleHopForPancakeV3() public {
        testProcessV3Swap(PANCAKE_V3_USDC_WETH, USDC, WETH, 40000e6, PANCAKE_V3_SWAP_CALLBACK);
        testProcessV3Swap(PANCAKE_V3_USDC_WETH, WETH, USDC, 10 ether, PANCAKE_V3_SWAP_CALLBACK);
    }

    // SUSHI <-> WETH on SushiSwap V3
    function test_processV3Swap_singleHopForSushiV3() public {
        testProcessV3Swap(SLP_V3_SUSHI_WETH, SUSHI, WETH, 50000 ether, UNISWAP_V3_SWAP_CALLBACK);
        testProcessV3Swap(SLP_V3_SUSHI_WETH, WETH, SUSHI, 10 ether, UNISWAP_V3_SWAP_CALLBACK);
    }

    function testProcessV3Swap(
        address pool,
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        bytes4 callbackSelector
    ) internal {
        deal(tokenIn, address(rp), amountIn);

        plan = plan.addPath(Encoder.encodeV3Swap(pool, tokenOut, callbackSelector));
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
        revertToState();
    }
}
