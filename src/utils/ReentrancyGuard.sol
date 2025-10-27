// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title ReentrancyGuard
/// @notice Utility base contract for preventing reentrant calls to a function.
abstract contract ReentrancyGuard {
    /// @notice Unauthorized reentrant call.
    error ReentrantCall();

    /// @dev Equivalent to: `uint32(bytes4(keccak256("ReentrantCall()"))) | 1 << 71`.
    uint256 private constant REENTRANCY_GUARD_SLOT = 0x800000000037ed32e8;

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        assembly ("memory-safe") {
            if tload(REENTRANCY_GUARD_SLOT) {
                mstore(0x00, REENTRANCY_GUARD_SLOT) // ReentrantCall()
                revert(0x1c, 0x04)
            }
            tstore(REENTRANCY_GUARD_SLOT, 0x01)
        }
    }

    function _nonReentrantAfter() private {
        assembly ("memory-safe") {
            tstore(REENTRANCY_GUARD_SLOT, 0x00)
        }
    }
}
