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
    ) internal returns (uint256 amountOut) {}
}
