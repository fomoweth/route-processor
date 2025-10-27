// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title IRouteProcessor
interface IRouteProcessor {
    /// @notice Processes an encoded route with a strict deadline check.
    /// @param route Encoded bytes stream of commands and parameters.
    /// @param deadline Unix timestamp beyond which execution is invalid.
    function processRoute(bytes calldata route, uint256 deadline) external payable;

    /// @notice Processes an encoded route without a deadline constraint.
    /// @param route Encoded bytes stream of commands and parameters.
    /// @dev Sequentially parses and executes each command from the stream.
    function processRoute(bytes calldata route) external payable;
}
