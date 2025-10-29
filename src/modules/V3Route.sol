// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Stream} from "src/types/Stream.sol";
import {CallbackValidation} from "src/utils/CallbackValidation.sol";

/// @title V3Route
/// @notice Route module for executing Uniswap V3 swaps with callback validation.
/// @dev Supports only single-hop exact-input swaps for a flow consistent with other protocols.
///		 Uses {CallbackValidation} to verify pool and selector context without storing factory/initCodeHash.
abstract contract V3Route is CallbackValidation {
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

    /// @dev Verifies callback via {CallbackValidation-verifyCallback} and pays the input token to the calling pool.
    ///		 The `data` payload carries only the token address (first 20 bytes).
    function handleV3Callback(int256 amount0Delta, int256 amount1Delta, bytes calldata data) internal verifyCallback {
        assembly ("memory-safe") {
            // Validate that at least one delta is positive
            if iszero(or(sgt(amount0Delta, 0x00), sgt(amount1Delta, 0x00))) {
                mstore(0x00, 0x11157667) // InvalidSwap()
                revert(0x1c, 0x04)
            }

            // Ensure payload length ≥ 20 bytes
            if lt(data.length, 0x14) {
                mstore(0x00, 0x3b99b53d) // InvalidDataLength()
                revert(0x1c, 0x04)
            }

            // Construct calldata for transfer
            mstore(0x00, 0xa9059cbb000000000000000000000000) // transfer(address,uint256)
            mstore(0x14, caller())

            switch sgt(amount0Delta, 0x00)
            case 0x01 { mstore(0x34, amount0Delta) }
            default { mstore(0x34, amount1Delta) }

            // Extract token address from first 20 bytes of `data`
            let token := shr(0x60, calldataload(data.offset))

            // Execute call to token
            if iszero(
                and(
                    or(eq(mload(0x00), 0x01), iszero(returndatasize())),
                    call(gas(), token, 0x00, 0x10, 0x44, 0x00, 0x20)
                )
            ) {
                mstore(0x00, 0x90b8ec18) // TransferFailed()
                revert(0x1c, 0x04)
            }

            // Clear scratch space
            mstore(0x34, 0x00)
        }
    }

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
    ) internal returns (uint256 amountOut) {
        // Parse optional callback selector from `stream`
        bytes4 callbackSelector = stream.parseBytes4();

        // Fallback to default Uniswap V3 callback selector if not provided
        if (callbackSelector == bytes4(0)) {
            callbackSelector = this.uniswapV3SwapCallback.selector;
        }

        // Authenticate swap callback and execute swap
        amountOut = swap(pool, recipient, tokenIn < tokenOut, amountIn, abi.encodePacked(tokenIn), callbackSelector);
    }

    /// @dev Executes low-level swap logic with callback validation for Uniswap V3 AMMs.
    function swap(
        address pool,
        address recipient,
        bool zeroForOne,
        uint256 amountSpecified,
        bytes memory data,
        bytes4 callbackSelector
    ) private prepareCallback(pool, callbackSelector) returns (uint256 amountReceived) {
        assembly ("memory-safe") {
            // Construct calldata for swap
            let ptr := mload(0x40)
            mstore(ptr, 0x128acb08) // swap(address,bool,int256,uint160,bytes)
            mstore(add(ptr, 0x20), recipient)
            mstore(add(ptr, 0x40), zeroForOne)
            mstore(add(ptr, 0x60), amountSpecified)
            switch zeroForOne
            case 0x00 { mstore(add(ptr, 0x80), MAX_SQRT_PRICE_LIMIT) }
            case 0x01 { mstore(add(ptr, 0x80), MIN_SQRT_PRICE_LIMIT) }
            mstore(add(ptr, 0xa0), 0xa0) // offset to bytes data
            mcopy(add(ptr, 0xc0), data, add(mload(data), 0x20))

            // Execute call to pool
            if iszero(call(gas(), pool, 0x00, add(ptr, 0x1c), add(mload(data), 0xc4), 0x00, 0x40)) {
                returndatacopy(ptr, 0x00, returndatasize())
                revert(ptr, returndatasize())
            }

            // Invert signed leg to get positive output from returndata (int256 amount0, int256 amount1)
            amountReceived := sub(0x00, mload(shl(0x05, zeroForOne)))
        }
    }
}
