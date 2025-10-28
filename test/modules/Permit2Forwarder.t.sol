// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {IAllowanceTransfer as IPermit2} from "permit2/interfaces/IAllowanceTransfer.sol";
import {Errors} from "src/libraries/Errors.sol";
import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {BaseTest} from "test/shared/BaseTest.sol";
import {Encoder} from "test/shared/Encoder.sol";
import {Permit2Utils} from "test/shared/Permit2Utils.sol";

contract Permit2ForwarderTest is BaseTest {
    using Permit2Utils for uint256;
    using SafeTransferLib for address;

    error InvalidSigner();

    address[] internal tokens = [DAI, USDC, USDT, WSTETH, WEETH, SFRXETH];

    Account internal mann;

    function setUp() public virtual override {
        super.setUp();

        vm.startPrank(cooper.addr);
        for (uint256 i = 0; i < tokens.length; ++i) {
            deal(tokens[i], cooper.addr, i < 3 ? scale(tokens[i], 50000 ether) : 10 ether);
            tokens[i].forceApprove(address(PERMIT2), MAX_UINT256);
            PERMIT2.approve(tokens[i], address(rp), MAX_UINT160, MAX_UINT48);
        }
        vm.stopPrank();

        mann = makeAccount("mann");
    }

    function test_permitSingle(uint256 seed) public {
        address token = random(tokens, seed);

        IPermit2.PermitDetails memory details = IPermit2.PermitDetails({
            token: token,
            amount: uint160(token.balanceOf(cooper.addr)),
            expiration: MAX_UINT48,
            nonce: 0
        });

        uint256 sigDeadline = vm.getBlockTimestamp() + 10;
        bytes memory signature = cooper.key.signPermit(details, address(rp), sigDeadline);
        bytes memory route = Encoder.encodePermit(details, sigDeadline, signature);

        vm.expectEmit(true, true, true, true);
        emit IPermit2.Permit(cooper.addr, token, address(rp), details.amount, MAX_UINT48, 0);

        vm.prank(cooper.addr);
        rp.processRoute(route);

        (uint160 amount, uint48 expiration, uint48 nonce) = PERMIT2.allowance(cooper.addr, token, address(rp));
        assertEq(amount, details.amount);
        assertEq(expiration, details.expiration);
        assertEq(nonce, details.nonce + 1);
    }

    function test_permitSingle_revertsOnInvalidSignature(uint256 seed) public {
        address token = random(tokens, seed);

        IPermit2.PermitDetails memory details = IPermit2.PermitDetails({
            token: token,
            amount: uint160(token.balanceOf(cooper.addr)),
            expiration: MAX_UINT48,
            nonce: 0
        });

        uint256 sigDeadline = vm.getBlockTimestamp() + 10;
        bytes memory signature = mann.key.signPermit(details, address(rp), sigDeadline);
        bytes memory route = Encoder.encodePermit(details, sigDeadline, signature);

        vm.expectRevert(InvalidSigner.selector);
        vm.prank(cooper.addr);
        rp.processRoute(route);
    }

    function test_permitBatch() public {
        vm.expectEmit(true, true, true, true);

        IPermit2.PermitDetails[] memory details = new IPermit2.PermitDetails[](tokens.length);
        for (uint256 i = 0; i < details.length; ++i) {
            details[i] = IPermit2.PermitDetails({
                token: tokens[i],
                amount: uint160(tokens[i].balanceOf(cooper.addr)),
                expiration: MAX_UINT48,
                nonce: 0
            });

            emit IPermit2.Permit(cooper.addr, details[i].token, address(rp), details[i].amount, MAX_UINT48, 0);
        }

        uint256 sigDeadline = vm.getBlockTimestamp() + 10;
        bytes memory signature = cooper.key.signPermit(details, address(rp), sigDeadline);
        bytes memory route = Encoder.encodePermit(details, sigDeadline, signature);

        vm.prank(cooper.addr);
        rp.processRoute(route);

        for (uint256 i = 0; i < details.length; ++i) {
            (uint160 amount, uint48 expiration, uint48 nonce) =
                PERMIT2.allowance(cooper.addr, details[i].token, address(rp));
            assertEq(amount, details[i].amount);
            assertEq(expiration, MAX_UINT48);
            assertEq(nonce, 1);
        }
    }

    function test_permitBatch_revertsOnInvalidSignature() public {
        IPermit2.PermitDetails[] memory details = new IPermit2.PermitDetails[](tokens.length);
        for (uint256 i = 0; i < details.length; ++i) {
            details[i] = IPermit2.PermitDetails({
                token: tokens[i],
                amount: uint160(tokens[i].balanceOf(cooper.addr)),
                expiration: MAX_UINT48,
                nonce: 0
            });
        }

        uint256 sigDeadline = vm.getBlockTimestamp() + 10;
        bytes memory signature = mann.key.signPermit(details, address(rp), sigDeadline);
        bytes memory route = Encoder.encodePermit(details, sigDeadline, signature);

        vm.expectRevert(InvalidSigner.selector);
        vm.prank(cooper.addr);
        rp.processRoute(route);
    }

    function test_permit2TransferFrom(uint256 seed) public {
        address token = random(tokens, seed);
        uint256 amount = token.balanceOf(cooper.addr);
        bytes memory route = Encoder.encodeTransferFrom(token, amount);

        vm.expectEmit(true, true, true, true);
        emit IERC20.Transfer(cooper.addr, address(rp), amount);

        vm.prank(cooper.addr);
        rp.processRoute(route);
        assertEq(token.balanceOf(address(rp)), amount);
    }

    function test_permit2BatchTransferFrom() public {
        IPermit2.AllowanceTransferDetails[] memory details = new IPermit2.AllowanceTransferDetails[](tokens.length);
        for (uint256 i = 0; i < details.length; ++i) {
            details[i] = IPermit2.AllowanceTransferDetails({
                from: cooper.addr,
                to: address(rp),
                amount: uint160(tokens[i].balanceOf(cooper.addr)),
                token: tokens[i]
            });

            vm.expectEmit(true, true, true, true, details[i].token);
            emit IERC20.Transfer(cooper.addr, address(rp), details[i].amount);
        }

        bytes memory route = Encoder.encodeTransferFrom(details);
        vm.prank(cooper.addr);
        rp.processRoute(route);

        for (uint256 i = 0; i < details.length; ++i) {
            assertEq(details[i].token.balanceOf(details[i].to), details[i].amount);
        }
    }

    function test_permit2BatchTransferFrom_revertsWithInvalidSender() public {
        IPermit2.AllowanceTransferDetails[] memory details = new IPermit2.AllowanceTransferDetails[](tokens.length);
        for (uint256 i = 0; i < details.length; ++i) {
            details[i] = IPermit2.AllowanceTransferDetails({
                from: mann.addr,
                to: address(rp),
                amount: uint160(tokens[i].balanceOf(cooper.addr)),
                token: tokens[i]
            });
        }

        bytes memory route = Encoder.encodeTransferFrom(details);
        vm.expectRevert(Errors.InvalidSender.selector);
        vm.prank(cooper.addr);
        rp.processRoute(route);
    }

    function test_permit2BatchTransferFrom_revertsWithInvalidRecipient() public {
        IPermit2.AllowanceTransferDetails[] memory details = new IPermit2.AllowanceTransferDetails[](tokens.length);
        for (uint256 i = 0; i < details.length; ++i) {
            details[i] = IPermit2.AllowanceTransferDetails({
                from: cooper.addr,
                to: mann.addr,
                amount: uint160(tokens[i].balanceOf(cooper.addr)),
                token: tokens[i]
            });
        }

        bytes memory route = Encoder.encodeTransferFrom(details);
        vm.expectRevert(Errors.InvalidRecipient.selector);
        vm.prank(cooper.addr);
        rp.processRoute(route);
    }
}
