// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

/// @title SafeTransferLib
/// @notice Minimal, memory-safe library for performing ERC20 and native ETH transfers with low-level call safety.
/// @dev Provides fail-safe approve, transfer, transferFrom, and view helpers with unified handling of ERC20 and ETH.
///      Inspired by Solady's SafeTransferLib but extended to support native ETH transfers.
library SafeTransferLib {
    /// @dev Thrown when ERC20 `approve()` call fails.
    error ApprovalFailed();

    /// @dev Thrown when ERC20 `transfer()` call fails.
    error TransferFailed();

    /// @dev Thrown when native ETH transfer fails.
    error TransferNativeFailed();

    /// @dev Thrown when ERC20 `transferFrom()` call fails.
    error TransferFromFailed();

    /// @dev Thrown when attempting to `transferFrom` native ETH incorrectly.
    error TransferFromNativeFailed();

    /// @dev Thrown when querying ERC20 `decimals()` fails.
    error DecimalsQueryFailed();

    /// @dev Thrown when querying ERC20 `totalSupply()` fails.
    error TotalSupplyQueryFailed();

    /// @notice Safely approves a spender for the given ERC20 token.
    /// @dev Executes only if `token` contains code (not ETH).
    function safeApprove(address token, address spender, uint256 amount) internal {
        assembly ("memory-safe") {
            if extcodesize(token) {
                mstore(0x00, 0x095ea7b3000000000000000000000000) // approve(address,uint256)
                mstore(0x14, spender)
                mstore(0x34, amount)
                if iszero(
                    and(
                        or(eq(mload(0x00), 0x01), iszero(returndatasize())),
                        call(gas(), token, 0x00, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    mstore(0x00, 0x8164f842) // ApprovalFailed()
                    revert(0x1c, 0x04)
                }
                mstore(0x34, 0x00)
            }
        }
    }

    /// @notice Forces an approval by resetting it to zero before re-approving.
    /// @dev Executes only if `token` contains code (not ETH).
    ///		 Some ERC20 tokens (e.g. USDT) require approval reset before updating allowance.
    function forceApprove(address token, address spender, uint256 amount) internal {
        assembly ("memory-safe") {
            if extcodesize(token) {
                mstore(0x00, 0x095ea7b3000000000000000000000000) // approve(address,uint256)
                mstore(0x14, spender)
                mstore(0x34, amount)
                if iszero(
                    and(
                        or(eq(mload(0x00), 0x01), iszero(returndatasize())),
                        call(gas(), token, 0x00, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    // Reset to zero and try again
                    mstore(0x34, 0x00)
                    pop(call(gas(), token, 0x00, 0x10, 0x44, codesize(), 0x00))
                    mstore(0x34, amount)
                    if iszero(
                        and(
                            or(eq(mload(0x00), 0x01), iszero(returndatasize())),
                            call(gas(), token, 0x00, 0x10, 0x44, 0x00, 0x20)
                        )
                    ) {
                        mstore(0x00, 0x8164f842) // ApprovalFailed()
                        revert(0x1c, 0x04)
                    }
                }
                mstore(0x34, 0x00)
            }
        }
    }

    /// @notice Safely transfers ERC20 tokens or native ETH to a recipient.
    /// @dev Automatically detects if `token` is a contract (ERC20) or native ETH.
    function safeTransfer(address token, address recipient, uint256 amount) internal {
        assembly ("memory-safe") {
            switch iszero(extcodesize(token))
            case 0x00 {
                // ERC20 transfer
                mstore(0x00, 0xa9059cbb000000000000000000000000) // transfer(address,uint256)
                mstore(0x14, recipient)
                mstore(0x34, amount)
                if iszero(
                    and(
                        or(eq(mload(0x00), 0x01), iszero(returndatasize())),
                        call(gas(), token, 0x00, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    mstore(0x00, 0x90b8ec18) // TransferFailed()
                    revert(0x1c, 0x04)
                }
                mstore(0x34, 0x00)
            }
            default {
                // Native ETH transfer
                if iszero(call(gas(), recipient, amount, codesize(), 0x00, codesize(), 0x00)) {
                    mstore(0x00, 0xb06a467a) // TransferNativeFailed()
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /// @notice Safely executes `transferFrom()` for ERC20 tokens or transfers native ETH if no code.
    /// @dev For native ETH, only allow msg.sender → this contract transfers.
    function safeTransferFrom(address token, address sender, address recipient, uint256 value) internal {
        assembly ("memory-safe") {
            switch iszero(extcodesize(token))
            case 0x00 {
                // ERC20 transferFrom
                let ptr := mload(0x40)
                mstore(0x0c, 0x23b872dd000000000000000000000000) // transferFrom(address,address,uint256)
                mstore(0x2c, shl(0x60, sender))
                mstore(0x40, recipient)
                mstore(0x60, value)
                if iszero(
                    and(
                        or(eq(mload(0x00), 0x01), iszero(returndatasize())),
                        call(gas(), token, 0x00, 0x1c, 0x64, 0x00, 0x20)
                    )
                ) {
                    mstore(0x00, 0x7939f424) // TransferFromFailed()
                    revert(0x1c, 0x04)
                }
                mstore(0x60, 0x00)
                mstore(0x40, ptr)
            }
            default {
                // For native ETH, the call reverts unless sender == msg.sender and recipient == address(this)
                if or(lt(callvalue(), value), or(iszero(eq(sender, caller())), iszero(eq(recipient, address())))) {
                    mstore(0x00, 0xa20c5180) // TransferFromNativeFailed()
                    revert(0x1c, 0x04)
                }
            }
        }
    }

    /// @notice Reads the current allowance between `owner` and `spender`.
    /// @dev Returns zero if the allowance query fails or reverts.
    ///		 For native ETH, returns max uint256 (no approval needed).
    function allowance(address token, address owner, address spender) internal view returns (uint256 r) {
        assembly ("memory-safe") {
            switch iszero(extcodesize(token))
            case 0x00 {
                mstore(0x00, 0xdd62ed3e000000000000000000000000) // allowance(address,address)
                mstore(0x14, owner)
                mstore(0x34, spender)
                r := mul(mload(0x20), and(gt(returndatasize(), 0x1f), staticcall(gas(), token, 0x10, 0x44, 0x20, 0x20)))
                mstore(0x34, 0x00)
            }
            default { r := not(0x00) }
        }
    }

    /// @notice Returns the balance of an account for ERC20 or native ETH.
    /// @dev Returns zero if the balance query fails or reverts.
    function balanceOf(address token, address account) internal view returns (uint256 r) {
        assembly ("memory-safe") {
            switch iszero(extcodesize(token))
            case 0x00 {
                mstore(0x00, 0x70a08231000000000000000000000000) // balanceOf(address)
                mstore(0x14, account)
                r := mul(mload(0x20), and(gt(returndatasize(), 0x1f), staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)))
            }
            default { r := balance(account) }
        }
    }

    /// @notice Returns this contract's own token or ETH balance.
    /// @dev Returns zero if the balance query fails or reverts.
    function balanceOfSelf(address token) internal view returns (uint256 r) {
        assembly ("memory-safe") {
            switch iszero(extcodesize(token))
            case 0x00 {
                mstore(0x00, 0x70a08231000000000000000000000000) // balanceOf(address)
                mstore(0x14, address())
                r := mul(mload(0x20), and(gt(returndatasize(), 0x1f), staticcall(gas(), token, 0x10, 0x24, 0x20, 0x20)))
            }
            default { r := selfbalance() }
        }
    }

    /// @notice Returns token decimals or defaults to 18 for native ETH, reverting if the call fails.
    function decimals(address token) internal view returns (uint8 r) {
        assembly ("memory-safe") {
            switch iszero(extcodesize(token))
            case 0x00 {
                mstore(0x00, 0x313ce567) // decimals()
                if iszero(and(gt(returndatasize(), 0x1f), staticcall(gas(), token, 0x1c, 0x04, 0x00, 0x20))) {
                    mstore(0x00, 0x1eecbb65) // DecimalsQueryFailed()
                    revert(0x1c, 0x04)
                }
                r := mload(0x00)
            }
            default { r := 0x12 } // Default to 18 decimals for ETH
        }
    }

    /// @notice Returns total supply of a token, reverting if the call fails.
    function totalSupply(address token) internal view returns (uint256 r) {
        assembly ("memory-safe") {
            mstore(0x00, 0x18160ddd) // totalSupply()
            if iszero(and(gt(returndatasize(), 0x1f), staticcall(gas(), token, 0x1c, 0x04, 0x00, 0x20))) {
                mstore(0x00, 0x54cd9435) // TotalSupplyQueryFailed()
                revert(0x1c, 0x04)
            }
            r := mload(0x00)
        }
    }
}
