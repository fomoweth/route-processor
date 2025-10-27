// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IRouteProcessor} from "src/interfaces/IRouteProcessor.sol";
import {Commands} from "src/libraries/Commands.sol";
import {Errors} from "src/libraries/Errors.sol";
import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {Protocol} from "src/types/Enums.sol";
import {Stream, createStream} from "src/types/Stream.sol";
import {NativeWrapper} from "src/modules/NativeWrapper.sol";
import {Permit2Forwarder} from "src/modules/Permit2Forwarder.sol";
import {CurveRoute} from "src/modules/CurveRoute.sol";
import {V2Route} from "src/modules/V2Route.sol";
import {V3Route} from "src/modules/V3Route.sol";
import {ReentrancyGuard} from "src/utils/ReentrancyGuard.sol";

/// @title RouteProcessor
/// @notice Stateless route execution engine that interprets and executes encoded command streams.
contract RouteProcessor is
    IRouteProcessor,
    ReentrancyGuard,
    NativeWrapper,
    Permit2Forwarder,
    CurveRoute,
    V2Route,
    V3Route
{
    using SafeTransferLib for address;

    /// @dev Constant flag for denoting a “use contract balance” input amount.
    uint256 private constant CONTRACT_BALANCE = 0x8000000000000000000000000000000000000000000000000000000000000000;

    modifier checkDeadline(uint256 deadline) {
        _checkDeadline(deadline);
        _;
    }

    /// @inheritdoc IRouteProcessor
    function processRoute(bytes calldata route, uint256 deadline) external payable checkDeadline(deadline) {
        processRoute(route);
    }

    /// @inheritdoc IRouteProcessor
    function processRoute(bytes calldata route) public payable nonReentrant {
        Stream stream = createStream(route);
        while (stream.isNotEmpty()) {
            uint256 command = stream.parseUint8();
            if (command == Commands.SWAP) {
                processSwap(stream);
            } else if (command == Commands.PERMIT2_PERMIT) {
                permitSingle(stream);
            } else if (command == Commands.PERMIT2_PERMIT_BATCH) {
                permitBatch(stream);
            } else if (command == Commands.PERMIT2_TRANSFER_FROM) {
                permit2TransferFrom(stream);
            } else if (command == Commands.PERMIT2_TRANSFER_FROM_BATCH) {
                permit2BatchTransferFrom(stream);
            } else if (command == Commands.SWEEP) {
                address token = stream.parseAddress();
                address recipient = stream.parseAddress();
                uint256 amountMinimum = stream.parseUint256();
                sweep(token, recipient, amountMinimum);
            } else {
                revert Errors.InvalidCommand();
            }
        }
    }

    function processSwap(Stream stream) internal returns (uint256 amountOut) {}

    function sweep(address token, address recipient, uint256 amountMinimum) internal {}

    /// @dev Reverts if the provided deadline has already passed.
    function _checkDeadline(uint256 deadline) private view {
        assembly ("memory-safe") {
            if gt(timestamp(), deadline) {
                mstore(0x00, 0x1ab7da6b) // DeadlineExpired()
                revert(0x1c, 0x04)
            }
        }
    }

    /// @notice Accepts native ETH deposits from swaps or unwrapping operations.
    receive() external payable {}
}
