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
    ) internal returns (uint256 amountOut) {
        // Parse optional fee from stream (0 means default)
        uint24 fee = stream.parseUint24();

        // Transfer input tokens into the pool
        tokenIn.safeTransfer(pool, amountIn);

        // Determine swap direction and execute swap
        amountOut = swap(pool, recipient, fee, tokenIn < tokenOut, tokenIn.balanceOf(pool));
    }

    /// @dev Executes low-level swap logic with reserve fetching and fee-adjusted output for Uniswap V2 AMMs.
    function swap(address pool, address recipient, uint24 fee, bool zeroForOne, uint256 amountIn)
        private
        returns (uint256 amountOut)
    {
        assembly ("memory-safe") {
            // If no `fee` was provided, fallback to default 0.3%
            if iszero(fee) { fee := DEFAULT_V2_FEE }

            // Query reserves
            mstore(0x00, 0x0902f1ac) // getReserves()

            if iszero(staticcall(gas(), pool, 0x1c, 0x04, 0x00, 0x40)) {
                mstore(0x00, 0xd8417525) // ReservesQueryFailed()
                revert(0x1c, 0x04)
            }

            // Decode reserves based on swap direction and validate
            let reserveIn := mload(shl(0x05, iszero(zeroForOne)))
            let reserveOut := mload(shl(0x05, iszero(iszero(zeroForOne))))

            if or(iszero(reserveIn), iszero(reserveOut)) {
                mstore(0x00, 0x945e9268) // InsufficientReserves()
                revert(0x1c, 0x04)
            }

            // Compute net input delta: (Δin = currentBalance - reserveIn)
            // The passed `amountIn` is the current balance of the `pool`,
            // so subtracting reserveIn yields the net tokens sent in.
            amountIn := sub(amountIn, reserveIn)

            if iszero(amountIn) {
                mstore(0x00, 0xdf5b2ee6) // InsufficientAmountIn()
                revert(0x1c, 0x04)
            }

            // Compute output using V2 constant-product formula:
            // amountOut = (reserveOut * Δin * (1 - fee)) / (reserveIn * 1e6 + Δin * (1 - fee))
            amountIn := mul(amountIn, sub(FEE_DENOMINATOR, fee))
            amountOut := div(mul(reserveOut, amountIn), add(mul(reserveIn, FEE_DENOMINATOR), amountIn))

            if iszero(amountOut) {
                mstore(0x00, 0xe52970aa) // InsufficientAmountOut()
                revert(0x1c, 0x04)
            }

            // Construct calldata for swap
            let ptr := mload(0x40)
            mstore(ptr, 0x022c0d9f) // swap(uint256,uint256,address,bytes)
            mstore(add(ptr, 0x20), mul(amountOut, iszero(zeroForOne)))
            mstore(add(ptr, 0x40), mul(amountOut, iszero(iszero(zeroForOne))))
            mstore(add(ptr, 0x60), recipient)
            mstore(add(ptr, 0x80), 0x80) // offset to empty bytes
            mstore(add(ptr, 0xa0), 0x00) // empty bytes length

            // Execute call to pool
            if iszero(call(gas(), pool, 0x00, add(ptr, 0x1c), 0xa4, codesize(), 0x00)) {
                returndatacopy(ptr, 0x00, returndatasize())
                revert(ptr, returndatasize())
            }
        }
    }
}
