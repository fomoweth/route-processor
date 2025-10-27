// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {Stream} from "src/types/Stream.sol";
import {CallbackValidation} from "src/utils/CallbackValidation.sol";

/// @title V3Route
/// @notice Route module for executing Uniswap V3 swaps with callback validation.
abstract contract V3Route is CallbackValidation {
    using SafeTransferLib for address;

    /// @dev Thrown when the length of callback data is invalid.
    error InvalidDataLength();

    /// @dev Thrown if both deltas are non-positive, meaning no token was requested.
    error InvalidSwap();

    /// @dev Equivalent to: `TickMath.MAX_SQRT_RATIO - 1`.
    uint160 private constant MAX_SQRT_PRICE_LIMIT = 1461446703485210103287273052203988822378723970341;

    /// @dev Equivalent to: `TickMath.MIN_SQRT_RATIO + 1`.
    uint160 private constant MIN_SQRT_PRICE_LIMIT = 4295128740;

    /// @dev Entrypoint for Uniswap V3 pool swap callback.
    function uniswapV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external {
        handleV3Callback(amount0Delta, amount1Delta, data);
    }

    /// @dev Entrypoint for Pancake V3 pool swap callback.
    function pancakeV3SwapCallback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) external {
        handleV3Callback(amount0Delta, amount1Delta, data);
    }

    function handleV3Callback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) internal {}

    /// @notice Executes a Uniswap V3 swap route.
    /// @dev Authenticates callback via {CallbackValidation-prepareCallback}.
    /// @param stream Encoded route stream.
    /// @param recipient Address receiving the swap output.
    /// @param pool Address of the target Uniswap V3 pool.
    /// @param tokenIn Address of the input token being swapped.
    /// @param tokenOut Address of the output token expected.
    /// @param amountIn Amount of the input token being provided.
    /// @return amountOut Amount of the output token received from the swap.
    function processV3Swap(
        Stream stream,
        address recipient,
        address pool,
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) internal returns (uint256 amountOut) {}
}
