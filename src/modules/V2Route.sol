// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {Stream} from "src/types/Stream.sol";

/// @title V2Route
/// @notice Route module for executing Uniswap V2 swaps with dynamic fee inference.
abstract contract V2Route {
    using SafeTransferLib for address;

    /// @dev Thrown when either of the reserves is zero.
    error InsufficientReserves();

    /// @dev Thrown when the pool's `getReserves()` call fails.
    error ReservesQueryFailed();

    /// @dev Fee denominator for Uniswap V2 AMMs.
    uint24 private constant FEE_DENOMINATOR = 1_000_000;

    /// @dev Default swap fee for Uniswap V2 AMMs (0.3% = 3000 / 1_000_000).
    uint24 private constant DEFAULT_V2_FEE = 3000;

    /// @notice Executes a Uniswap V2 swap route.
    /// @param stream Encoded route stream.
    /// @param recipient Address receiving the swap output.
    /// @param pool Address of the target Uniswap V2 pool.
    /// @param tokenIn Address of the input token.
    /// @param tokenOut Address of the output token.
    /// @param amountIn Amount of the input token being provided.
    /// @return amountOut Amount of the output token received from the swap.
    function processV2Swap(
        Stream stream,
        address recipient,
        address pool,
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) internal returns (uint256 amountOut) {}
}
