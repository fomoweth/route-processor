// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Protocol} from "./Enums.sol";

using StreamLibrary for Stream global;

/// @dev A 256-bit pointer type referencing the current parsing position in memory.
type Stream is uint256;

/// @notice Initializes a new {Stream} from a bytes array.
/// @param data The bytes data to stream through.
/// @return stream A {Stream} object containing start and end pointers.
function createStream(bytes memory data) pure returns (Stream stream) {
    assembly ("memory-safe") {
        stream := mload(0x40)
        mstore(0x40, add(stream, 0x40))
        mstore(stream, data)
        mstore(add(stream, 0x20), add(data, mload(data)))
    }
}

/// @title StreamLibrary
/// @notice Provides efficient low-level read operations for decoding arbitrary-typed data from a {Stream}.
/// @dev Each function advances the internal cursor automatically.
library StreamLibrary {
    /// @dev Checks if the `stream` still has unread bytes (cursor < end position).
    function isNotEmpty(Stream stream) internal pure returns (bool result) {
        assembly ("memory-safe") {
            result := lt(mload(stream), mload(add(stream, 0x20)))
        }
    }

    /// @dev Reads an address (20 bytes) and advances the cursor.
    function parseAddress(Stream stream) internal pure returns (address result) {
        assembly ("memory-safe") {
            let pos := add(mload(stream), 0x14)
            result := and(mload(pos), 0xffffffffffffffffffffffffffffffffffffffff)
            mstore(stream, pos)
        }
    }

    /// @dev Reads one byte and interprets it as a boolean.
    function parseBool(Stream stream) internal pure returns (bool result) {
        assembly ("memory-safe") {
            let pos := add(mload(stream), 0x01)
            result := and(mload(pos), 0xff)
            mstore(stream, pos)
        }
    }

    /// @dev Reads and casts one byte as a {Protocol} enum.
    function parseProtocol(Stream stream) internal pure returns (Protocol result) {
        assembly ("memory-safe") {
            let pos := add(mload(stream), 0x01)
            result := and(mload(pos), 0xff)
            mstore(stream, pos)
        }
    }

    /// @dev Reads one byte and returns a uint8.
    function parseUint8(Stream stream) internal pure returns (uint8 result) {
        assembly ("memory-safe") {
            let pos := add(mload(stream), 0x01)
            result := and(mload(pos), 0xff)
            mstore(stream, pos)
        }
    }

    /// @dev Reads 2 bytes and returns a uint16.
    function parseUint16(Stream stream) internal pure returns (uint16 result) {
        assembly ("memory-safe") {
            let pos := add(mload(stream), 0x02)
            result := and(mload(pos), 0xffff)
            mstore(stream, pos)
        }
    }

    /// @dev Reads 3 bytes and returns a uint24.
    function parseUint24(Stream stream) internal pure returns (uint24 result) {
        assembly ("memory-safe") {
            let pos := add(mload(stream), 0x03)
            result := and(mload(pos), 0xffffff)
            mstore(stream, pos)
        }
    }

    /// @dev Reads 6 bytes and returns a uint48.
    function parseUint48(Stream stream) internal pure returns (uint48 result) {
        assembly ("memory-safe") {
            let pos := add(mload(stream), 0x06)
            result := and(mload(pos), 0xffffffffffff)
            mstore(stream, pos)
        }
    }

    /// @dev Reads 16 bytes and returns a uint128.
    function parseUint128(Stream stream) internal pure returns (uint128 result) {
        assembly ("memory-safe") {
            let pos := add(mload(stream), 0x10)
            result := and(mload(pos), 0xffffffffffffffffffffffffffff)
            mstore(stream, pos)
        }
    }

    /// @dev Reads 20 bytes and returns a uint160.
    function parseUint160(Stream stream) internal pure returns (uint160 result) {
        assembly ("memory-safe") {
            let pos := add(mload(stream), 0x14)
            result := mload(pos)
            result := and(mload(pos), 0xffffffffffffffffffffffffffffffffffffffff)
            mstore(stream, pos)
        }
    }

    /// @dev Reads 32 bytes and returns a uint256.
    function parseUint256(Stream stream) internal pure returns (uint256 result) {
        assembly ("memory-safe") {
            let pos := add(mload(stream), 0x20)
            result := mload(pos)
            mstore(stream, pos)
        }
    }

    /// @dev Reads 32 bytes and returns a int256.
    function parseInt256(Stream stream) internal pure returns (int256 result) {
        assembly ("memory-safe") {
            let pos := add(mload(stream), 0x20)
            result := mload(pos)
            mstore(stream, pos)
        }
    }

    /// @dev Reads 4 bytes and returns a bytes4 (function selector).
    function parseBytes4(Stream stream) internal pure returns (bytes4 result) {
        assembly ("memory-safe") {
            let pos := mload(stream)
            result := mload(add(pos, 0x20))
            mstore(stream, add(pos, 0x04))
        }
    }

    /// @dev Reads 32 bytes and returns a bytes32.
    function parseBytes32(Stream stream) internal pure returns (bytes32 result) {
        assembly ("memory-safe") {
            let pos := add(mload(stream), 0x20)
            result := mload(pos)
            mstore(stream, pos)
        }
    }

    /// @dev Reads a dynamic bytes array and advances the cursor by its length.
    function parseBytes(Stream stream) internal pure returns (bytes memory result) {
        assembly ("memory-safe") {
            result := add(mload(stream), 0x20)
            mstore(stream, add(result, mload(result)))
        }
    }
}
