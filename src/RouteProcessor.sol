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
/// @dev Integrates modular route processors (Curve, Uniswap V2/V3, and native LST/LRT handlers)
///      into a unified entrypoint. Each command is decoded and dispatched inline for maximum
///      gas efficiency. Enforces atomic execution, reentrancy protection, and deadline validation.
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

    /// @notice Reverts if the provided `deadline` has already passed.
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

    /// @notice Executes a multi-hop swap sequence across one or more pools.
    /// @dev Iterates through the encoded pools within the route stream, invoking
    ///      the appropriate module (Curve, UniswapV2, UniswapV3, or NativeWrapper)
    ///      for each hop. Supports both ERC20 and native tokens.
    function processSwap(Stream stream) internal returns (uint256 amountOut) {
        address recipient = stream.parseAddress();
        address tokenIn = stream.parseAddress();
        uint256 amountIn = stream.parseUint256();
        uint256 amountOutMinimum = stream.parseUint256();
        uint256 numPools = stream.parseUint8();

        if (amountIn == CONTRACT_BALANCE) amountIn = tokenIn.balanceOfSelf();
        if (amountIn == 0) revert Errors.InsufficientAmountIn();
        if (numPools == 0) revert Errors.InvalidPath();

        unchecked {
            uint256 lastIndex = numPools - 1;
            amountOut = amountIn;

            for (uint256 i = 0; i < numPools; ++i) {
                Protocol protocol = stream.parseProtocol();
                address pool = stream.parseAddress();
                address tokenOut = stream.parseAddress();

                if (tokenIn == tokenOut) revert Errors.IdenticalAddresses();

                address receiver = i != lastIndex ? address(this) : recipient;

                if (protocol == Protocol.Curve) {
                    amountOut = processCurve(stream, receiver, pool, tokenIn, tokenOut, amountOut);
                } else if (protocol == Protocol.UniswapV2) {
                    amountOut = processV2Swap(stream, receiver, pool, tokenIn, tokenOut, amountOut);
                } else if (protocol == Protocol.UniswapV3) {
                    amountOut = processV3Swap(stream, receiver, pool, tokenIn, tokenOut, amountOut);
                } else {
                    amountOut = processNative(stream, receiver, protocol, pool, tokenIn, tokenOut, amountOut);
                }
                tokenIn = tokenOut;
            }
        }

        if (amountOut < amountOutMinimum) revert Errors.InsufficientAmountOut();
    }

    function sweep(address token, address recipient, uint256 amountMinimum) internal {
        uint256 balance = token.balanceOfSelf();
        if (balance < amountMinimum) revert Errors.InsufficientBalance();
        if (balance != 0) token.safeTransfer(recipient, balance);
    }

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
