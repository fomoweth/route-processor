// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title Errors
/// @notice Centralized custom error definitions used across all RouteProcessor modules.
library Errors {
    /// @notice Thrown when the token amount exceeds 160 bits (2^160 - 1).
    error AmountOverflow();

    /// @notice Thrown when the transaction deadline has already passed.
    error DeadlineExpired();

    /// @notice Thrown when identical token addresses are provided for input and output.
    error IdenticalAddresses();

    /// @notice Thrown when the provided input amount is too small.
    error InsufficientAmountIn();

    /// @notice Thrown when the obtained output amount is below the required minimum.
    error InsufficientAmountOut();

    /// @notice Thrown when an invalid or unsupported command byte is parsed from the route stream.
    error InvalidCommand();

    /// @notice Thrown when an operation is not supported or mismatched with the current protocol.
    error InvalidOperation();

    /// @notice Thrown when the route stream contains an invalid or incomplete path.
    error InvalidPath();

    /// @notice Thrown when the payer address does not match the expected source of tokens.
    error InvalidPayer();

    /// @notice Thrown when the provided pool address is invalid or non-existent.
    error InvalidPool();

    /// @notice Thrown when the protocol identifier does not correspond to a known integration.
    error InvalidProtocol();

    /// @notice Thrown when the recipient address is zero or otherwise invalid.
    error InvalidRecipient();

    /// @notice Thrown when the provided signature is malformed, has invalid length, or fails verification.
    error InvalidSignature();
}
