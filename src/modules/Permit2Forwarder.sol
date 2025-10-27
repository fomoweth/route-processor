// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Stream} from "src/types/Stream.sol";

/// @title Permit2Forwarder
/// @notice Module providing integration with Uniswap’s Permit2 contract for token approval and transfer flows.
abstract contract Permit2Forwarder {
    /// @dev Canonical Permit2 contract address deployed by Uniswap Labs.
    address private constant PERMIT2 = 0x000000000022D473030F116dDEE9F6B43aC78BA3;

    function permitSingle(Stream stream) internal {}

    function permitBatch(Stream stream) internal {}

    function permit2TransferFrom(Stream stream) internal {}

    function permit2BatchTransferFrom(Stream stream) internal {}
}
