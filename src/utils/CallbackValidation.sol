// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title CallbackValidation
/// @notice Utility base contract for safely authorizing and validating swap callbacks.
/// @dev - Provides a transient storage–based mechanism for verifying callback origin and selector.
///		 - Ensures that only the expected pool and selector may invoke the callback within the same transaction.
abstract contract CallbackValidation {
    /// @dev Thrown when the provided callback caller address is invalid.
    error InvalidCaller();

    /// @dev Thrown when the provided callback selector is invalid.
    error InvalidSelector();

    /// @dev Thrown when the actual callback context does not match the pre-authorized context.
    error UnauthorizedCallback();

    /// @notice Prepares the callback validation context.
    /// @param caller Expected pool address that will invoke the callback.
    /// @param selector Expected function selector for the callback.
    /// @dev Uses transient storage to avoid persistent state changes and minimize gas cost.
    modifier prepareCallback(address caller, bytes4 selector) {
        _prepareCallback(caller, selector);
        _;
    }

    /// @notice Verifies that the current callback call matches the expected context.
    /// @dev The transient slot is cleared immediately after validation.
    modifier verifyCallback() {
        _verifyCallback();
        _;
    }

    /// @dev Writes the callback validation context into transient storage.
    function _prepareCallback(address expectedCaller, bytes4 expectedSelector) private {
        assembly ("memory-safe") {
            // Ensure caller is non-zero (avoid null or precompile)
            if iszero(shl(0x60, expectedCaller)) {
                mstore(0x00, 0x48f5c3ed) // InvalidCaller()
                revert(0x1c, 0x04)
            }

            // Ensure selector is not empty
            if iszero(expectedSelector) {
                mstore(0x00, 0x7352d91c) // InvalidSelector()
                revert(0x1c, 0x04)
            }

            // Record authorization
            mstore(0x00, shr(0x60, shl(0x60, expectedCaller)))
            tstore(keccak256(0x00, 0x20), shr(0xe0, expectedSelector))
        }
    }

    /// @dev Validates the active callback against the stored authorization context.
    function _verifyCallback() private {
        assembly ("memory-safe") {
            // Compute key based on msg.sender
            mstore(0x00, caller())
            let slot := keccak256(0x00, 0x20)

            // Verify that stored selector matches calldata selector
            if iszero(eq(tload(slot), shr(0xe0, calldataload(0x00)))) {
                mstore(0x00, 0xf5c6c81a) // UnauthorizedCallback()
                revert(0x1c, 0x04)
            }

            // Clear transient slot for reuse
            tstore(slot, 0x00)
        }
    }
}
