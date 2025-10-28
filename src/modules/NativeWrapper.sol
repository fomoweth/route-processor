// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Protocol} from "src/types/Enums.sol";
import {Stream} from "src/types/Stream.sol";

/// @title NativeWrapper
/// @notice Unified execution layer for ETH and ETH-derivative operations.
/// @dev Routes encoded (protocol, operation) pairs into protocol-specific deposit, withdraw, and wrapping calls.
///      Supports native ETH, LST (Liquid Staking Tokens), and LRT (Liquid Restaking Tokens) flows.
abstract contract NativeWrapper {
    /// @notice Executes ETH-native wrapping, staking, and restaking operations across supported LST and LRT protocols.
    /// @param stream Encoded route stream.
    /// @param recipient Address to receive the operation output.
    /// @param protocol LST protocol type identifier.
    /// @param pool Address of the target pool.
    /// @param tokenIn Address of the input token.
    /// @param tokenOut Address of the output token.
    /// @param amount Amount of the input token being provided.
    /// @return received Amount of the output token received from the operation.
    function processNative(
        Stream stream,
        address recipient,
        Protocol protocol,
        address pool,
        address tokenIn,
        address tokenOut,
        uint256 amount
    ) internal returns (uint256 received) {
        uint16 operation = stream.parseUint16();

        assembly ("memory-safe") {
            function bubbleRevert(p) {
                returndatacopy(p, 0x00, returndatasize())
                revert(p, returndatasize())
            }

            function balanceOfSelf(t) -> r {
                switch iszero(extcodesize(t))
                case 0x00 {
                    mstore(0x00, 0x70a08231000000000000000000000000) // balanceOf(address)
                    mstore(0x14, address())
                    r := mul(mload(0x20), and(gt(returndatasize(), 0x1f), staticcall(gas(), t, 0x10, 0x24, 0x20, 0x20)))
                }
                default { r := selfbalance() }
            }

            function approve(t, a, v) {
                mstore(0x00, 0x095ea7b3000000000000000000000000) // approve(address,uint256)
                mstore(0x14, a)
                mstore(0x34, v)
                if iszero(
                    and(
                        or(eq(mload(0x00), 0x01), iszero(returndatasize())),
                        call(gas(), t, 0x00, 0x10, 0x44, 0x00, 0x20)
                    )
                ) {
                    mstore(0x34, 0x00)
                    pop(call(gas(), t, 0x00, 0x10, 0x44, 0x00, 0x20))
                    mstore(0x34, v)
                    if iszero(
                        and(
                            or(eq(mload(0x00), 0x01), iszero(returndatasize())),
                            call(gas(), t, 0x00, 0x10, 0x44, 0x00, 0x20)
                        )
                    ) {
                        mstore(0x00, 0x8164f842) // ApprovalFailed()
                        revert(0x1c, 0x04)
                    }
                }
                mstore(0x34, 0x00)
            }

            function deposit(t, p, v) -> r {
                mstore(p, 0x6e553f65) // deposit(uint256,address)
                mstore(add(p, 0x20), v)
                mstore(add(p, 0x40), address())
                if iszero(call(gas(), t, 0x00, add(p, 0x1c), 0x44, p, 0x20)) { bubbleRevert(p) }
                r := mload(p)
            }

            function redeem(t, p, v) -> r {
                mstore(p, 0xba087652) // redeem(uint256,address,address)
                mstore(add(p, 0x20), v)
                mstore(add(p, 0x40), address())
                mstore(add(p, 0x60), address())
                if iszero(call(gas(), t, 0x00, add(p, 0x1c), 0x64, p, 0x20)) { bubbleRevert(p) }
                r := mload(p)
            }

            function fetch(t, p, s) -> r {
                if iszero(staticcall(gas(), t, p, s, 0x00, 0x20)) { bubbleRevert(p) }
                r := mload(0x00)
            }

            function execute(t, v, p, s, o) -> r {
                r := balanceOfSelf(o)
                if iszero(call(gas(), t, v, p, s, 0x00, 0x00)) { bubbleRevert(p) }
                r := sub(balanceOfSelf(o), r)
            }

            let ptr := mload(0x40)

            switch protocol
            // WETH
            case 0x00 {
                switch operation
                // ETH -> WETH
                case 0x0001 {
                    mstore(ptr, 0xd0e30db0) // deposit()
                    if iszero(call(gas(), tokenOut, amount, add(ptr, 0x1c), 0x04, codesize(), 0x00)) {
                        bubbleRevert(ptr)
                    }
                    received := amount
                }
                // WETH -> ETH
                case 0x0100 {
                    mstore(ptr, 0x2e1a7d4d) // withdraw(uint256)
                    mstore(add(ptr, 0x20), amount)
                    if iszero(call(gas(), tokenIn, 0x00, add(ptr, 0x1c), 0x24, codesize(), 0x00)) { bubbleRevert(ptr) }
                    received := amount
                }
                default {
                    mstore(0x00, 0x398d4d32) // InvalidOperation()
                    revert(0x1c, 0x04)
                }
            }
            // Rocket
            case 0x04 {
                switch operation
                // ETH -> rETH
                case 0x0002 {
                    mstore(ptr, 0xd0e30db0) // deposit()
                    received := execute(pool, amount, add(ptr, 0x1c), 0x04, tokenOut)
                }
                default {
                    mstore(0x00, 0x398d4d32) // InvalidOperation()
                    revert(0x1c, 0x04)
                }
            }
            // Swell
            case 0x05 {
                switch operation
                // ETH -> swETH
                case 0x0002 {
                    mstore(ptr, 0xd0e30db0) // deposit()
                    received := execute(tokenOut, amount, add(ptr, 0x1c), 0x04, tokenOut)
                }
                default {
                    mstore(0x00, 0x398d4d32) // InvalidOperation()
                    revert(0x1c, 0x04)
                }
            }
            // Binance
            case 0x06 {
                switch operation
                // ETH -> wBETH
                case 0x0002 {
                    mstore(ptr, 0xf340fa01) // deposit(address)
                    received := execute(tokenOut, amount, add(ptr, 0x1c), 0x24, tokenOut)
                }
                default {
                    mstore(0x00, 0x398d4d32) // InvalidOperation()
                    revert(0x1c, 0x04)
                }
            }
            // Stader
            case 0x07 {
                switch operation
                // ETH -> ETHx
                case 0x0002 {
                    mstore(ptr, 0xf340fa01) // deposit(address)
                    mstore(add(ptr, 0x20), address())
                    received := execute(pool, amount, add(ptr, 0x1c), 0x24, tokenOut)
                }
                default {
                    mstore(0x00, 0x398d4d32) // InvalidOperation()
                    revert(0x1c, 0x04)
                }
            }
            // StakeWise
            case 0x08 {
                switch operation
                // ETH -> osETH
                case 0x0002 {
                    mstore(0x00, 0xc6e6f592) // convertToShares(uint256)
                    mstore(0x20, amount)
                    mstore(ptr, 0x36fe59d2) // depositAndMintOsToken(address,uint256,address)
                    mstore(add(ptr, 0x20), address())
                    mstore(add(ptr, 0x40), fetch(pool, 0x1c, 0x24))
                    received := execute(pool, amount, add(ptr, 0x1c), 0x64, tokenOut)
                }
                default {
                    mstore(0x00, 0x398d4d32) // InvalidOperation()
                    revert(0x1c, 0x04)
                }
            }
            // Lido
            case 0x09 {
                switch operation
                // ETH -> stETH
                case 0x0002 { received := execute(tokenOut, amount, codesize(), 0x00, tokenOut) }
                // ETH -> wstETH
                case 0x0003 { received := execute(tokenOut, amount, codesize(), 0x00, tokenOut) }
                // stETH -> wstETH
                case 0x0203 {
                    approve(tokenIn, tokenOut, amount)
                    mstore(ptr, 0xea598cb0) // wrap(uint256)
                    mstore(add(ptr, 0x20), amount)
                    received := execute(tokenOut, 0x00, add(ptr, 0x1c), 0x24, tokenOut)
                }
                // wstETH -> stETH
                case 0x0302 {
                    mstore(ptr, 0xde0e9a3e) // unwrap(uint256)
                    mstore(add(ptr, 0x20), amount)
                    received := execute(tokenIn, 0x00, add(ptr, 0x1c), 0x24, tokenOut)
                }
                default {
                    mstore(0x00, 0x398d4d32) // InvalidOperation()
                    revert(0x1c, 0x04)
                }
            }
            // EtherFi
            case 0x0a {
                // 0x0de371e2: eETH()
                // 0xd0e30db0: deposit()
                // 0x561bddf8: amountForShare(uint256)
                // 0x3a53acb0: sharesForAmount(uint256)
                // 0xd044fe9b: getWeETHByeETH(uint256)
                // 0x94626044: getEETHByWeETH(uint256)
                // 0xea598cb0: wrap(uint256)
                // 0xde0e9a3e: unwrap(uint256)
                mstore(ptr, 0x0de371e2d0e30db0561bddf83a53acb0d044fe9b94626044ea598cb0de0e9a3e)

                switch operation
                // ETH -> eETH
                case 0x0002 { received := execute(pool, amount, add(ptr, 0x04), 0x04, tokenOut) }
                // ETH -> weETH
                case 0x0003 {
                    tokenIn := fetch(pool, ptr, 0x04)
                    amount := execute(pool, amount, add(ptr, 0x04), 0x04, tokenIn)

                    approve(tokenIn, tokenOut, amount)
                    mstore(add(ptr, 0x1c), amount)
                    received := execute(tokenOut, 0x00, add(ptr, 0x18), 0x24, tokenOut)
                }
                // eETH -> weETH
                case 0x0203 {
                    approve(tokenIn, tokenOut, amount)
                    mstore(add(ptr, 0x1c), amount)
                    received := execute(tokenOut, 0x00, add(ptr, 0x18), 0x24, tokenOut)
                }
                // weETH -> eETH
                case 0x0302 {
                    mstore(add(ptr, 0x20), amount)
                    received := execute(tokenIn, 0x00, add(ptr, 0x1c), 0x24, tokenOut)
                }
                default {
                    mstore(0x00, 0x398d4d32) // InvalidOperation()
                    revert(0x1c, 0x04)
                }
            }
            // Frax Ether
            case 0x0b {
                switch operation
                // ETH -> frxETH
                case 0x0002 { received := execute(pool, amount, codesize(), 0x00, tokenOut) }
                // ETH -> sfrxETH
                case 0x0003 {
                    mstore(ptr, 0x4dcd4547) // submitAndDeposit(address)
                    mstore(add(ptr, 0x20), address())
                    received := execute(pool, amount, add(ptr, 0x1c), 0x24, tokenOut)
                }
                // frxETH -> sfrxETH
                case 0x0203 {
                    approve(tokenIn, tokenOut, amount)
                    received := deposit(tokenOut, ptr, amount)
                }
                // sfrxETH -> frxETH
                case 0x0302 { received := redeem(tokenIn, ptr, amount) }
                default {
                    mstore(0x00, 0x398d4d32) // InvalidOperation()
                    revert(0x1c, 0x04)
                }
            }
            // Origin
            case 0x0c {
                switch operation
                // WETH -> oETH
                case 0x0102 {
                    approve(tokenIn, pool, amount)
                    mstore(ptr, 0x156e29f6) // mint(address,uint256,uint256)
                    mstore(add(ptr, 0x20), tokenIn)
                    mstore(add(ptr, 0x40), amount)
                    mstore(add(ptr, 0x60), amount)
                    received := execute(pool, 0x00, add(ptr, 0x1c), 0x64, tokenOut)
                }
                // WETH -> woETH
                case 0x0103 {
                    approve(tokenIn, pool, amount)
                    mstore(ptr, 0x156e29f6) // mint(address,uint256,uint256)
                    mstore(add(ptr, 0x20), tokenIn)
                    mstore(add(ptr, 0x40), amount)
                    mstore(add(ptr, 0x60), amount)
                    mstore(0x00, 0x5802a172) // oUSD()
                    tokenIn := fetch(pool, 0x1c, 0x04)
                    amount := execute(pool, 0x00, add(ptr, 0x1c), 0x64, tokenIn)

                    approve(tokenIn, tokenOut, amount)
                    received := deposit(tokenOut, ptr, amount)
                }
                // oETH -> woETH
                case 0x0203 {
                    approve(tokenIn, tokenOut, amount)
                    received := deposit(tokenOut, ptr, amount)
                }
                // woETH -> oETH
                case 0x0302 { received := redeem(tokenIn, ptr, amount) }
                default {
                    mstore(0x00, 0x398d4d32) // InvalidOperation()
                    revert(0x1c, 0x04)
                }
            }
            // Ankr
            case 0x0d {
                // 0x9fa65c56: stakeAndClaimAethC()
                // 0xeb834a2c: stakeAndClaimAethB()
                // 0x6482a22f: lockShares(uint256)
                // 0xee031373: unlockShares(uint256)
                // 0x53616373: bondsToShares(uint256)
                // 0x6c58d43d: sharesToBonds(uint256)
                mstore(ptr, 0x9fa65c56eb834a2c6482a22fee031373536163736c58d43d0000000000000000)

                switch operation
                // ETH -> ankrETH
                case 0x0002 { received := execute(pool, amount, ptr, 0x04, tokenOut) }
                // ETH -> aETHb
                case 0x0003 { received := execute(pool, amount, add(ptr, 0x04), 0x04, tokenOut) }
                // ankrETH -> aETHb
                case 0x0203 {
                    approve(tokenIn, tokenOut, amount)
                    mstore(add(ptr, 0x0c), amount)
                    received := execute(tokenOut, 0x00, add(ptr, 0x08), 0x24, tokenOut)
                }
                // aETHb -> ankrETH
                case 0x0302 {
                    mstore(add(ptr, 0x14), amount)
                    mstore(add(ptr, 0x10), fetch(tokenIn, add(ptr, 0x10), 0x24))
                    received := execute(tokenIn, 0x00, add(ptr, 0x0c), 0x24, tokenOut)
                }
                default {
                    mstore(0x00, 0x398d4d32) // InvalidOperation()
                    revert(0x1c, 0x04)
                }
            }
            // Mantle
            case 0x0e {
                // 0x4fb3ccc5: accountant()
                // 0x5001f3b5: base()
                // 0xd8932ae7: cmETH()
                // 0xee99205c: stakingContract()
                // 0xfbfa77cf: vault()
                // 0x4461ff05: ethToMETH(uint256)
                // 0x5890c11c: mETHToETH(uint256)
                mstore(ptr, 0x4fb3ccc55001f3b5d8932ae7ee99205cfbfa77cf4461ff055890c11c00000000)

                switch operation
                // ETH -> mETH
                case 0x0002 {
                    mstore(add(ptr, 0x18), amount)
                    mstore(add(ptr, 0x20), 0xa694fc3a) // stake(uint256)
                    mstore(add(ptr, 0x40), fetch(pool, add(ptr, 0x14), 0x24))
                    received := execute(pool, amount, add(ptr, 0x3c), 0x24, tokenOut)
                }
                // ETH -> cmETH
                case 0x0004 {
                    tokenIn := fetch(fetch(pool, ptr, 0x04), add(ptr, 0x04), 0x04)
                    let stakingContract := fetch(tokenIn, add(ptr, 0x0c), 0x04)

                    mstore(add(ptr, 0x18), amount)
                    mstore(add(ptr, 0x20), 0xa694fc3a) // stake(uint256)
                    mstore(add(ptr, 0x40), fetch(stakingContract, add(ptr, 0x14), 0x24))
                    amount := execute(stakingContract, amount, add(ptr, 0x3c), 0x24, tokenIn)

                    approve(tokenIn, fetch(pool, add(ptr, 0x10), 0x04), amount)
                    mstore(add(ptr, 0x20), 0x0efe6a8b) // deposit(address,uint256,uint256)
                    mstore(add(ptr, 0x40), tokenIn)
                    mstore(add(ptr, 0x60), amount)
                    received := execute(pool, 0x00, add(ptr, 0x3c), 0x64, tokenOut)
                }
                // mETH -> cmETH
                case 0x0204 {
                    approve(tokenIn, fetch(pool, add(ptr, 0x10), 0x04), amount)
                    mstore(ptr, 0x0efe6a8b) // deposit(address,uint256,uint256)
                    mstore(add(ptr, 0x20), tokenIn)
                    mstore(add(ptr, 0x40), amount)
                    received := execute(pool, 0x00, add(ptr, 0x1c), 0x64, tokenOut)
                }
                default {
                    mstore(0x00, 0x398d4d32) // InvalidOperation()
                    revert(0x1c, 0x04)
                }
            }
            // Renzo
            case 0x0f {
                switch operation
                // ETH -> ezETH
                case 0x0004 {
                    mstore(ptr, 0xf6326fb3) // depositETH()
                    received := execute(pool, amount, add(ptr, 0x1c), 0x04, tokenOut)
                }
                // stETH -> ezETH
                case 0x0204 {
                    approve(tokenIn, pool, amount)
                    mstore(ptr, 0x47e7ef24) // deposit(address,uint256)
                    mstore(add(ptr, 0x20), tokenIn)
                    mstore(add(ptr, 0x40), amount)
                    received := execute(pool, 0x00, add(ptr, 0x1c), 0x44, tokenOut)
                }
                // wstETH -> pzETH
                case 0x0304 {
                    approve(tokenIn, tokenOut, amount)
                    received := deposit(tokenOut, ptr, amount)
                }
                default {
                    mstore(0x00, 0x398d4d32) // InvalidOperation()
                    revert(0x1c, 0x04)
                }
            }
            // Puffer
            case 0x10 {
                switch operation
                // ETH -> pufETH
                case 0x0004 {
                    mstore(ptr, 0x2d2da806) // depositETH(address)
                    mstore(add(ptr, 0x20), address())
                    received := execute(tokenOut, amount, add(ptr, 0x1c), 0x24, tokenOut)
                }
                // WETH -> pufETH
                case 0x0104 {
                    approve(tokenIn, tokenOut, amount)
                    received := deposit(tokenOut, ptr, amount)
                }
                // stETH -> pufETH
                case 0x0204 {
                    approve(tokenIn, tokenOut, amount)
                    mstore(ptr, 0xf6dbd16f) // depositStETH(uint256,address)
                    mstore(add(ptr, 0x20), 0x19208451) // getSharesByPooledEth(uint256)
                    mstore(add(ptr, 0x40), amount)
                    mstore(add(ptr, 0x20), fetch(tokenIn, add(ptr, 0x3c), 0x24))
                    mstore(add(ptr, 0x40), address())
                    received := execute(tokenOut, 0x00, add(ptr, 0x1c), 0x44, tokenOut)
                }
                // pufETH -> WETH
                case 0x0401 { received := redeem(tokenIn, ptr, amount) }
                default {
                    mstore(0x00, 0x398d4d32) // InvalidOperation()
                    revert(0x1c, 0x04)
                }
            }
            default {
                mstore(0x00, 0x07f1c7d4) // InvalidProtocol()
                revert(0x1c, 0x04)
            }

            if iszero(received) {
                mstore(0x00, 0x910f3412) // InsufficientAmountReceived()
                revert(0x1c, 0x04)
            }

            if iszero(eq(recipient, address())) {
                switch iszero(extcodesize(tokenOut))
                case 0x00 {
                    mstore(0x00, 0xa9059cbb000000000000000000000000) // transfer(address,uint256)
                    mstore(0x14, recipient)
                    mstore(0x34, received)
                    if iszero(
                        and(
                            or(eq(mload(0x00), 0x01), iszero(returndatasize())),
                            call(gas(), tokenOut, 0x00, 0x10, 0x44, 0x00, 0x20)
                        )
                    ) {
                        mstore(0x00, 0x90b8ec18) // TransferFailed()
                        revert(0x1c, 0x04)
                    }
                    mstore(0x34, 0x00)
                }
                default {
                    if iszero(call(gas(), recipient, received, codesize(), 0x00, codesize(), 0x00)) {
                        mstore(0x00, 0xb06a467a) // TransferNativeFailed()
                        revert(0x1c, 0x04)
                    }
                }
            }
        }
    }
}
