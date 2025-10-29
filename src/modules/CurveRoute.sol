// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {Stream} from "src/types/Stream.sol";

/// @title CurveRoute
/// @notice Route module for executing Curve swaps across both stable and crypto pools.
abstract contract CurveRoute {
    using SafeTransferLib for address;

    /// @dev `exchange()` function selectors
    ///		 - 0x3df02124: exchange(int128,int128,uint256,uint256)
    ///		 - 0xa6417ed6: exchange_underlying(int128,int128,uint256,uint256)
    ///		 - 0xed4ae2b8: exchange(int128,int128,uint256,uint256,bool)
    ///		 - 0xbf5ed056: exchange_underlying(int128,int128,uint256,uint256,bool)
    ///		 - 0x5b41b908: exchange(uint256,uint256,uint256,uint256)
    ///		 - 0x65b2489b: exchange_underlying(uint256,uint256,uint256,uint256)
    ///		 - 0x394747c5: exchange(uint256,uint256,uint256,uint256,bool)
    ///		 - 0xcb7558f1: exchange_underlying(uint256,uint256,uint256,uint256,bool)
    uint256 private constant EXCHANGE_SELECTORS = 0x3df02124a6417ed6ed4ae2b8bf5ed0565b41b90865b2489b394747c5cb7558f1;

    /// @notice Executes a Curve swap route.
    /// @dev Dynamically chooses the appropriate function selectors depending on pool type and flags.
    /// @param stream Encoded route stream (contains indices and flags).
    /// @param recipient Address receiving the swap output.
    /// @param pool Address of the target Curve pool.
    /// @param tokenIn Address of the input token being swapped.
    /// @param tokenOut Address of the output token expected.
    /// @param amountIn Amount of the input token being provided.
    /// @return amountOut Amount of the output token received from the swap.
    function processCurve(
        Stream stream,
        address recipient,
        address pool,
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) internal returns (uint256 amountOut) {
        // Decode parameters from stream.
        uint8 i = stream.parseUint8();
        uint8 j = stream.parseUint8();
        bool isCryptoPool = stream.parseBool();
        bool useUnderlying = stream.parseBool();
        bool useEth = stream.parseBool();

        // Approve input amount to Curve pool if ERC20
        tokenIn.forceApprove(pool, amountIn);

        // Perform the swap
        amountOut = exchange(pool, tokenIn, tokenOut, i, j, amountIn, isCryptoPool, useUnderlying, useEth);

        // Forward output tokens if recipient is external
        if (recipient != address(this)) tokenOut.safeTransfer(recipient, amountOut);
    }

    /// @dev Executes low-level swap logic using dynamic selector derivation for Curve AMMs.
    function exchange(
        address pool,
        address tokenIn,
        address tokenOut,
        uint8 i,
        uint8 j,
        uint256 dx,
        bool isCryptoPool,
        bool useUnderlying,
        bool useEth
    ) private returns (uint256 dy) {
        assembly ("memory-safe") {
            function isNative(t) -> r {
                r := iszero(extcodesize(t))
            }

            function balanceOfSelf(t) -> r {
                switch isNative(t)
                case 0x00 {
                    mstore(0x00, 0x70a08231000000000000000000000000) // balanceOf(address)
                    mstore(0x14, address())
                    r := mul(mload(0x20), and(gt(returndatasize(), 0x1f), staticcall(gas(), t, 0x10, 0x24, 0x20, 0x20)))
                }
                default { r := selfbalance() }
            }

            // Derive selector offset
            let offset := add(add(mul(isCryptoPool, 0x04), useUnderlying), mul(useEth, 0x02))
            let calldataSize := 0x84 // function selector + 4 arguments by default

            // Construct calldata with dynamic selector
            let ptr := mload(0x40)
            mstore(ptr, shr(shl(0x05, sub(0x07, offset)), EXCHANGE_SELECTORS))
            mstore(add(ptr, 0x20), i)
            mstore(add(ptr, 0x40), j)
            mstore(add(ptr, 0x60), dx)
            mstore(add(ptr, 0x80), 0x01) // min_dy

            // Include `useETH` flag for bool variant
            if useEth {
                mstore(add(ptr, 0xa0), isNative(tokenIn))
                calldataSize := add(calldataSize, 0x20)
            }

            // Fetch current balance of output token
            dy := balanceOfSelf(tokenOut)

            // Execute call to pool
            if iszero(call(gas(), pool, mul(dx, isNative(tokenIn)), add(ptr, 0x1c), calldataSize, codesize(), 0x00)) {
                returndatacopy(ptr, 0x00, returndatasize())
                revert(ptr, returndatasize())
            }

            // Compute output delta and validate
            dy := sub(balanceOfSelf(tokenOut), dy)
        }
    }
}
