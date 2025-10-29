// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title Commands
/// @notice RouteProcessor command opcodes representing executable actions within a route stream.
/// @dev Each command is represented as a single byte to minimize calldata size and simplify dispatching.
library Commands {
    /// @dev Executes a swap route (V2, V3, Curve, or Native LST/LRT).
    uint8 internal constant SWAP = 0x00;

    /// @dev Executes a Permit2 single-token approval.
    uint8 internal constant PERMIT2_PERMIT = 0x01;

    /// @dev Executes a Permit2 batch-token approval.
    uint8 internal constant PERMIT2_PERMIT_BATCH = 0x02;

    /// @dev Executes a Permit2 transferFrom for a single token.
    uint8 internal constant PERMIT2_TRANSFER_FROM = 0x03;

    /// @dev Executes a Permit2 batch transferFrom for multiple tokens.
    uint8 internal constant PERMIT2_TRANSFER_FROM_BATCH = 0x04;

    /// @dev Executes a sweep operation to transfer remaining token or native balances to the recipient.
    uint8 internal constant SWEEP = 0x05;
}
