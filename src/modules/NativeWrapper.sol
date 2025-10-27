// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Protocol} from "src/types/Enums.sol";
import {Stream} from "src/types/Stream.sol";

/// @title NativeWrapper
/// @notice Unified execution layer for ETH and ETH-derivative operations.
abstract contract NativeWrapper {
    /// @notice Executes ETH-native wrapping, staking, and restaking operations across supported LST and LRT protocols.
    /// @param stream Encoded route stream.
    /// @param recipient Address to receive the operation output.
    /// @param protocol LST protocol type identifier.
    /// @param pool Address of the target pool.
    /// @param tokenIn Address of the input token.
    /// @param tokenOut Address of the output token.
    /// @param amount Amount of the input token being provided.
    /// @return received Amount of the output token received from the operation.
    function processNative(
        Stream stream,
        address recipient,
        Protocol protocol,
        address pool,
        address tokenIn,
        address tokenOut,
        uint256 amount
    ) internal returns (uint256 received) {}
}
