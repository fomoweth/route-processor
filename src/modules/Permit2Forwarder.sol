// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Stream} from "src/types/Stream.sol";

/// @title Permit2Forwarder
/// @notice Module providing integration with Uniswap’s Permit2 contract for token approval and transfer flows.
abstract contract Permit2Forwarder {
    /// @dev Canonical Permit2 contract address deployed by Uniswap Labs.
    address private constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    /// @notice Executes a single-token permit approval on Permit2.
    /// @param stream Encoded stream containing:
    ///        - token address
    ///        - packed `word` (amount, expiration, nonce)
    ///        - signature deadline
    ///        - ECDSA signature
    function permitSingle(Stream stream) internal {
        address token = stream.parseAddress();
        uint256 word = stream.parseUint256();
        uint256 sigDeadline = stream.parseUint256();
        bytes memory signature = stream.parseBytes();

        assembly ("memory-safe") {
            // Construct calldata for permit
            let ptr := mload(0x40)
            mstore(ptr, 0x2b67b570) // permit(address,((address,uint160,uint48,uint48),address,uint256),bytes)
            mstore(add(ptr, 0x20), caller()) // owner
            mstore(add(ptr, 0x40), token)
            mstore(add(ptr, 0x60), shr(0x60, shl(0x60, word))) // amount
            mstore(add(ptr, 0x80), shr(0xd0, shl(0x30, word))) // expiration
            mstore(add(ptr, 0xa0), shr(0xd0, word)) // nonce
            mstore(add(ptr, 0xc0), address()) // spender
            mstore(add(ptr, 0xe0), sigDeadline)
            mstore(add(ptr, 0x100), 0x100) // offset to signature
            mcopy(add(ptr, 0x120), signature, add(mload(signature), 0x20)) // Append signature

            // Execute call to Permit2
            if iszero(call(gas(), PERMIT2, 0x00, add(ptr, 0x1c), add(mload(signature), 0x124), codesize(), 0x00)) {
                returndatacopy(ptr, 0x00, returndatasize())
                revert(ptr, returndatasize())
            }
        }
    }

    /// @notice Executes a batch permit approval on Permit2 for multiple tokens.
    /// @param stream Encoded stream containing:
    ///        - array of permit details (token, amount, expiration, nonce)
    ///        - signature deadline
    ///        - ECDSA signature
    function permitBatch(Stream stream) internal {
        bytes memory details = stream.parseBytes();
        uint256 sigDeadline = stream.parseUint256();
        bytes memory signature = stream.parseBytes();

        assembly ("memory-safe") {
            // Construct calldata for batch permit
            let offset := add(mload(details), 0xa0)
            let ptr := mload(0x40)
            mstore(ptr, 0x2a2d80d1) // permit(address,((address,uint160,uint48,uint48)[],address,uint256),bytes)
            mstore(add(ptr, 0x20), caller()) // owner
            mstore(add(ptr, 0x40), 0x60) // offset to permit struct
            mstore(add(ptr, 0x60), offset) // offset to signature
            mstore(add(ptr, 0x80), 0x60) // offset to details[]
            mstore(add(ptr, 0xa0), address()) // spender
            mstore(add(ptr, 0xc0), sigDeadline)
            mcopy(add(ptr, 0xe0), add(details, 0x40), mload(details))
            offset := add(offset, 0x20)
            mcopy(add(ptr, offset), signature, add(mload(signature), 0x20))
            offset := add(offset, add(mload(signature), 0x24))

            // Execute call to Permit2
            if iszero(call(gas(), PERMIT2, 0x00, add(ptr, 0x1c), offset, codesize(), 0x00)) {
                returndatacopy(ptr, 0x00, returndatasize())
                revert(ptr, returndatasize())
            }
        }
    }

    /// @notice Executes a single-token transferFrom on Permit2.
    /// @param stream Encoded stream containing token address and transfer amount.
    function permit2TransferFrom(Stream stream) internal {
        address token = stream.parseAddress();
        uint160 amount = stream.parseUint160();

        assembly ("memory-safe") {
            // Construct calldata for transfer
            let ptr := mload(0x40)
            mstore(ptr, 0x36c78516) // transferFrom(address,address,uint160,address)
            mstore(add(ptr, 0x20), caller())
            mstore(add(ptr, 0x40), address())
            mstore(add(ptr, 0x60), amount)
            mstore(add(ptr, 0x80), token)

            // Execute call to Permit2
            if iszero(call(gas(), PERMIT2, 0x00, add(ptr, 0x1c), 0x84, codesize(), 0x00)) {
                returndatacopy(ptr, 0x00, returndatasize())
                revert(ptr, returndatasize())
            }
        }
    }

    /// @notice Executes a batch transferFrom operation on Permit2 for multiple token transfers.
    /// @param stream Encoded stream containing array of transfer details (from, to, amount, token).
    /// @dev Validates each sender/recipient pair before invoking Permit2.
    function permit2BatchTransferFrom(Stream stream) internal {
        bytes memory transferDetails = stream.parseBytes();

        assembly ("memory-safe") {
            let guard := mload(transferDetails)

            // Validate sender/recipient pairs in the batch
            for { let offset := add(transferDetails, 0x60) } lt(offset, guard) { offset := add(offset, 0x80) } {
                if iszero(eq(mload(offset), caller())) {
                    mstore(0x00, 0xddb5de5e) // InvalidSender()
                    revert(0x1c, 0x04)
                }

                if iszero(eq(mload(add(offset, 0x20)), address())) {
                    mstore(0x00, 0x9c8d2cd2) // InvalidRecipient()
                    revert(0x1c, 0x04)
                }
            }

            // Construct calldata for batch transfer
            let ptr := mload(0x40)
            mstore(ptr, 0x0d58b1db) // transferFrom((address,address,uint160,address)[])
            mstore(add(ptr, 0x20), 0x20) // offset to transfer details[]
            mcopy(add(ptr, 0x40), add(transferDetails, 0x40), sub(guard, 0x20))

            // Execute call to Permit2
            if iszero(call(gas(), PERMIT2, 0x00, add(ptr, 0x1c), add(guard, 0x04), codesize(), 0x00)) {
                returndatacopy(ptr, 0x00, returndatasize())
                revert(ptr, returndatasize())
            }
        }
    }
}
