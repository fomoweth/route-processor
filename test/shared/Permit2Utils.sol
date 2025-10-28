// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {VmSafe} from "forge-std/Vm.sol";
import {IAllowanceTransfer} from "permit2/interfaces/IAllowanceTransfer.sol";

library Permit2Utils {
    VmSafe private constant vm = VmSafe(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

    bytes32 private constant PERMIT2_DOMAIN_SEPARATOR =
        0x866a5aba21966af95d6c7ab78eb2b2fc913915c28be3b9aa07cc04ff903e3f28;

    bytes32 private constant PERMIT_DETAILS_TYPEHASH =
        0x65626cad6cb96493bf6f5ebea28756c966f023ab9e8a83a7101849d5573b3678;

    bytes32 private constant PERMIT_SINGLE_TYPEHASH = 0xf3841cd1ff0085026a6327b620b67997ce40f282c88a8e905a7a5626e310f3d0;

    bytes32 private constant PERMIT_BATCH_TYPEHASH = 0xaf1b0d30d2cab0380e68f0689007e3254993c596f2fdd0aaa7f4d04f79440863;

    function signPermit(
        uint256 privateKey,
        IAllowanceTransfer.PermitDetails memory details,
        address spender,
        uint256 sigDeadline
    ) internal pure returns (bytes memory signature) {
        bytes32 structHash = keccak256(abi.encode(PERMIT_SINGLE_TYPEHASH, _hashDetails(details), spender, sigDeadline));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19\x01", PERMIT2_DOMAIN_SEPARATOR, structHash));

        (bytes32 r, bytes32 vs) = vm.signCompact(privateKey, messageHash);
        return bytes.concat(r, vs);
    }

    function signPermit(
        uint256 privateKey,
        IAllowanceTransfer.PermitDetails[] memory details,
        address spender,
        uint256 sigDeadline
    ) internal pure returns (bytes memory signature) {
        bytes32 structHash = keccak256(abi.encode(PERMIT_BATCH_TYPEHASH, _hashDetails(details), spender, sigDeadline));
        bytes32 messageHash = keccak256(abi.encodePacked("\x19\x01", PERMIT2_DOMAIN_SEPARATOR, structHash));

        (bytes32 r, bytes32 vs) = vm.signCompact(privateKey, messageHash);
        return bytes.concat(r, vs);
    }

    function _hashDetails(IAllowanceTransfer.PermitDetails memory details) private pure returns (bytes32) {
        return keccak256(abi.encode(PERMIT_DETAILS_TYPEHASH, details));
    }

    function _hashDetails(IAllowanceTransfer.PermitDetails[] memory details) private pure returns (bytes32) {
        bytes memory hashes;
        for (uint256 i; i < details.length; ++i) {
            hashes = bytes.concat(hashes, _hashDetails(details[i]));
        }
        return keccak256(hashes);
    }
}
