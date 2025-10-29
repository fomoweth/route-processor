// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IAllowanceTransfer} from "permit2/interfaces/IAllowanceTransfer.sol";
import {Commands} from "src/libraries/Commands.sol";
import {Errors} from "src/libraries/Errors.sol";
import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {AssetType, Protocol} from "src/types/Enums.sol";
import {BaseTest} from "test/shared/BaseTest.sol";
import {Permit2Utils} from "test/shared/Permit2Utils.sol";

contract RouteProcessorTest is BaseTest {
    using SafeTransferLib for address;

    address internal constant UNI_V3_USDC_WETH = 0x88e6A0c2dDD26FEEb64F039a2c41296FcB3f5640; // 0.05%
    address internal constant UNI_V3_WSTETH_WETH = 0x109830a1AAaD605BbF02a9dFA7B0B92EC2FB7dAa; // 0.01%
    address internal constant UNI_V3_WETH_WEETH = 0x202A6012894Ae5c288eA824cbc8A9bfb26A49b93; // 0.01%
    address internal constant UNI_V3_RETH_WETH = 0x553e9C493678d8606d6a5ba284643dB2110Df823; // 0.01%

    address internal constant UNI_V2_DAI_WETH = 0xA478c2975Ab1Ea89e8196811F51A7B7Ade33eB11;
    address internal constant UNI_V2_STETH_WETH = 0x4028DAAC072e492d34a3Afdbef0ba7e35D8b55C4;

    address internal constant STETH_POOL = 0xDC24316b9AE028F1497c275EB9192a3Ea0f67022; // ETH/stETH
    address internal constant FRXETH_POOL = 0x9c3B46C0Ceb5B9e304FCd6D88Fc50f7DD24B31Bc; // WETH/frxETH

    address internal constant TRYLSD = 0x2570f1bD5D2735314FC102eb12Fc1aFe9e6E7193; // wstETH/rETH/sfrxETH
    address internal constant TRICRYPTO = 0xD51a44d3FaE010294C616388b506AcdA1bfAAE46; // USDT/WBTC/WETH

    function test_processRoute_splitForSingleInputAndSingleOutput() public impersonate(cooper.addr) {
        address tokenIn = WETH;
        uint160 amountIn = 10 ether;
        uint160 amountTotal = 30 ether;

        deal(tokenIn, cooper.addr, amountTotal);
        tokenIn.forceApprove(address(PERMIT2), MAX_UINT256);

        IAllowanceTransfer.PermitDetails memory details =
            IAllowanceTransfer.PermitDetails({token: tokenIn, amount: amountTotal, expiration: MAX_UINT48, nonce: 0});

        uint256 sigDeadline = vm.getBlockTimestamp() + 10;
        bytes memory signature = Permit2Utils.signPermit(cooper.key, details, address(rp), sigDeadline);

        // Encode single permit and transferFrom
        plan = plan.add(Permit2Utils.encodePermit(details, sigDeadline, signature));
        plan = plan.add(Permit2Utils.encodeTransferFrom(tokenIn, amountTotal));

        // Encode route #1: WETH -> stETH -> wstETH via Uniswap V2
        plan = plan.addV2Swap(UNI_V2_STETH_WETH, STETH, 0);
        plan = plan.addWrap(Protocol.Lido, address(0), WSTETH, AssetType.LST, AssetType.WLST);
        plan = plan.finalizeSwap(murphy.addr, tokenIn, amountIn, 1);

        // Encode route #2: WETH -> wstETH via Uniswap V3
        plan = plan.addV3Swap(UNI_V3_WSTETH_WETH, WSTETH, bytes4(0));
        plan = plan.finalizeSwap(murphy.addr, tokenIn, amountIn, 1);

        // Encode route #3: WETH -> ETH -> stETH -> wstETH via Curve
        plan = plan.addWrap(Protocol.WETH, address(0), ETH, AssetType.WETH, AssetType.ETH);
        plan = plan.addCurve(STETH_POOL, STETH, 0, 1, false, false, false);
        plan = plan.addWrap(Protocol.Lido, address(0), WSTETH, AssetType.LST, AssetType.WLST);
        plan = plan.finalizeSwap(murphy.addr, tokenIn, amountIn, 1);

        bytes memory route = plan.encode();
        rp.processRoute(route);

        assertBalance(WSTETH, murphy.addr);
    }

    function test_processRoute_splitForSingleInputAndMultipleOutputs() public impersonate(cooper.addr) {
        uint8 n = 3;
        address tokenIn = WETH;
        uint160 amountIn = 10 ether;
        uint160 amountTotal = amountIn * n;

        deal(tokenIn, cooper.addr, amountTotal);
        tokenIn.forceApprove(address(PERMIT2), MAX_UINT256);

        IAllowanceTransfer.PermitDetails memory details =
            IAllowanceTransfer.PermitDetails({token: tokenIn, amount: amountTotal, expiration: MAX_UINT48, nonce: 0});

        uint256 sigDeadline = vm.getBlockTimestamp() + 10;
        bytes memory signature = Permit2Utils.signPermit(cooper.key, details, address(rp), sigDeadline);

        // Encode single permit and transferFrom
        plan = plan.add(Permit2Utils.encodePermit(details, sigDeadline, signature));
        plan = plan.add(Permit2Utils.encodeTransferFrom(tokenIn, amountTotal));

        // Encode route #1: WETH -> stETH -> wstETH via Uniswap V2
        plan = plan.addV2Swap(UNI_V2_STETH_WETH, STETH, 0);
        plan = plan.addWrap(Protocol.Lido, address(0), WSTETH, AssetType.LST, AssetType.WLST);
        plan = plan.finalizeSwap(murphy.addr, tokenIn, amountIn, 1);

        // Encode route #2: WETH -> weETH via Uniswap V3
        plan = plan.addV3Swap(UNI_V3_WETH_WEETH, WEETH, bytes4(0));
        plan = plan.finalizeSwap(murphy.addr, tokenIn, amountIn, 1);

        // Encode route #3: WETH -> frxETH -> sfrxETH via Curve
        plan = plan.addCurve(FRXETH_POOL, FRXETH, 0, 1, false, false, false);
        plan = plan.addWrap(Protocol.Frax, address(0), SFRXETH, AssetType.LST, AssetType.WLST);
        plan = plan.finalizeSwap(murphy.addr, tokenIn, amountIn, 1);

        bytes memory route = plan.encode();
        rp.processRoute(route);

        assertBalance(WSTETH, murphy.addr);
        assertBalance(WEETH, murphy.addr);
        assertBalance(SFRXETH, murphy.addr);
    }

    function test_processRoute_splitForMultipleInputsAndSingleOutput() public impersonate(cooper.addr) {
        uint8 n = 3;
        uint160 amountIn = 10 ether;
        uint256 amountTotal = amountIn * n;

        address[] memory tokens = new address[](n);
        tokens[0] = WSTETH;
        tokens[1] = WEETH;
        tokens[2] = SFRXETH;

        IAllowanceTransfer.AllowanceTransferDetails[] memory transferDetails =
            new IAllowanceTransfer.AllowanceTransferDetails[](n);

        IAllowanceTransfer.PermitDetails[] memory details = new IAllowanceTransfer.PermitDetails[](n);

        for (uint256 i = 0; i < n; ++i) {
            deal(tokens[i], cooper.addr, amountIn);
            tokens[i].forceApprove(address(PERMIT2), MAX_UINT256);

            transferDetails[i] = IAllowanceTransfer.AllowanceTransferDetails({
                from: cooper.addr,
                to: address(rp),
                amount: amountIn,
                token: tokens[i]
            });

            details[i] =
                IAllowanceTransfer.PermitDetails({token: tokens[i], amount: amountIn, expiration: MAX_UINT48, nonce: 0});
        }

        uint256 sigDeadline = vm.getBlockTimestamp() + 10;
        bytes memory signature = Permit2Utils.signPermit(cooper.key, details, address(rp), sigDeadline);

        // Encode batch permit and transferFrom
        plan = plan.add(Permit2Utils.encodePermit(details, sigDeadline, signature));
        plan = plan.add(Permit2Utils.encodeTransferFrom(transferDetails));

        // Encode route #1: wstETH -> stETH -> WETH -> ETH via Uniswap V2
        plan = plan.addWrap(Protocol.Lido, address(0), STETH, AssetType.WLST, AssetType.LST);
        plan = plan.addV2Swap(UNI_V2_STETH_WETH, WETH, 0);
        plan = plan.addWrap(Protocol.WETH, address(0), ETH, AssetType.WETH, AssetType.ETH);
        plan = plan.finalizeSwap(murphy.addr, tokens[0], amountIn, 1);

        // Encode route #2: weETH -> WETH -> ETH via Uniswap V3
        plan = plan.addV3Swap(UNI_V3_WETH_WEETH, WETH, bytes4(0));
        plan = plan.addWrap(Protocol.WETH, address(0), ETH, AssetType.WETH, AssetType.ETH);
        plan = plan.finalizeSwap(murphy.addr, tokens[1], amountIn, 1);

        // Encode route #3: sfrxETH -> frxETH -> WETH -> ETH via Curve
        plan = plan.addWrap(Protocol.Frax, address(0), FRXETH, AssetType.WLST, AssetType.LST);
        plan = plan.addCurve(FRXETH_POOL, WETH, 1, 0, false, false, false);
        plan = plan.addWrap(Protocol.WETH, address(0), ETH, AssetType.WETH, AssetType.ETH);
        plan = plan.finalizeSwap(murphy.addr, tokens[2], amountIn, 1);

        bytes memory route = plan.encode();
        rp.processRoute(route);

        assertGt(murphy.addr.balance, amountTotal);
    }

    function test_processRoute_splitForMultipleInputsAndMultipleOutputs() public impersonate(cooper.addr) {
        uint8 n = 3;

        address[] memory tokens = new address[](n);
        tokens[0] = DAI;
        tokens[1] = USDC;
        tokens[2] = USDT;

        uint160[] memory amounts = new uint160[](n);
        amounts[0] = 10000 ether;
        amounts[1] = 10000e6;
        amounts[2] = 10000e6;

        IAllowanceTransfer.AllowanceTransferDetails[] memory transferDetails =
            new IAllowanceTransfer.AllowanceTransferDetails[](n);

        IAllowanceTransfer.PermitDetails[] memory details = new IAllowanceTransfer.PermitDetails[](n);

        for (uint256 i = 0; i < n; ++i) {
            deal(tokens[i], cooper.addr, amounts[i]);
            tokens[i].forceApprove(address(PERMIT2), MAX_UINT256);

            transferDetails[i] = IAllowanceTransfer.AllowanceTransferDetails({
                from: cooper.addr,
                to: address(rp),
                amount: amounts[i],
                token: tokens[i]
            });

            details[i] = IAllowanceTransfer.PermitDetails({
                token: tokens[i],
                amount: amounts[i],
                expiration: MAX_UINT48,
                nonce: 0
            });
        }

        uint256 sigDeadline = vm.getBlockTimestamp() + 10;
        bytes memory signature = Permit2Utils.signPermit(cooper.key, details, address(rp), sigDeadline);

        // Encode batch permit and transferFrom
        plan = plan.add(Permit2Utils.encodePermit(details, sigDeadline, signature));
        plan = plan.add(Permit2Utils.encodeTransferFrom(transferDetails));

        // Encode route #1: DAI -> WETH -> stETH -> wstETH via Uniswap V2
        plan = plan.addV2Swap(UNI_V2_DAI_WETH, WETH, 0);
        plan = plan.addV2Swap(UNI_V2_STETH_WETH, STETH, 0);
        plan = plan.addWrap(Protocol.Lido, address(0), WSTETH, AssetType.LST, AssetType.WLST);
        plan = plan.finalizeSwap(murphy.addr, tokens[0], amounts[0], 1);

        // Encode route #2: USDC -> WETH -> weETH via Uniswap V3
        plan = plan.addV3Swap(UNI_V3_USDC_WETH, WETH, bytes4(0));
        plan = plan.addV3Swap(UNI_V3_WETH_WEETH, WEETH, bytes4(0));
        plan = plan.finalizeSwap(murphy.addr, tokens[1], amounts[1], 1);

        // Encode route #3: USDT -> WETH -> frxETH -> sfrxETH via Curve
        plan = plan.addCurve(TRICRYPTO, WETH, 0, 2, true, false, true);
        plan = plan.addCurve(FRXETH_POOL, FRXETH, 0, 1, false, false, false);
        plan = plan.addWrap(Protocol.Frax, address(0), SFRXETH, AssetType.LST, AssetType.WLST);
        plan = plan.finalizeSwap(murphy.addr, tokens[2], amounts[2], 1);

        bytes memory route = plan.encode();
        rp.processRoute(route);

        assertBalance(WSTETH, murphy.addr);
        assertBalance(WEETH, murphy.addr);
        assertBalance(SFRXETH, murphy.addr);
    }

    function test_processRoute_complexRoute() public impersonate(cooper.addr) {
        address tokenIn = WETH;
        uint160 amountIn = 10 ether;

        deal(tokenIn, cooper.addr, amountIn);
        tokenIn.forceApprove(address(PERMIT2), MAX_UINT256);

        IAllowanceTransfer.PermitDetails memory details =
            IAllowanceTransfer.PermitDetails({token: tokenIn, amount: amountIn, expiration: MAX_UINT48, nonce: 0});

        uint256 sigDeadline = vm.getBlockTimestamp() + 10;
        bytes memory signature = Permit2Utils.signPermit(cooper.key, details, address(rp), sigDeadline);

        // Encode single permit and transferFrom
        plan = plan.add(Permit2Utils.encodePermit(details, sigDeadline, signature));
        plan = plan.add(Permit2Utils.encodeTransferFrom(tokenIn, amountIn));

        // Encode route for WETH -> frxETH -> sfrxETH -> rETH -> WETH -> stETH -> wstETH
        // WETH -> frxETH via Curve
        plan = plan.addCurve(FRXETH_POOL, FRXETH, 0, 1, false, false, false);
        // frxETH -> sfrxETH
        plan = plan.addWrap(Protocol.Frax, address(0), SFRXETH, AssetType.LST, AssetType.WLST);
        // sfrxETH -> rETH via Curve
        plan = plan.addCurve(TRYLSD, RETH, 2, 1, true, false, false);
        // rETH -> WETH via Uniswap V3
        plan = plan.addV3Swap(UNI_V3_RETH_WETH, WETH, bytes4(0));
        // WETH -> stETH via Uniswap V2
        plan = plan.addV2Swap(UNI_V2_STETH_WETH, STETH, 0);
        // stETH -> wstETH
        plan = plan.addWrap(Protocol.Lido, address(0), WSTETH, AssetType.LST, AssetType.WLST);
        plan = plan.finalizeSwap(murphy.addr, tokenIn, amountIn, 1);

        bytes memory route = plan.encode();
        rp.processRoute(route);

        assertBalance(WSTETH, murphy.addr);
    }

    function test_sweep_native() public {
        address token = ETH;
        uint256 amount = 1 ether;

        deal(token, address(rp), amount);

        // Encode sweep for native token
        plan = plan.add(abi.encodePacked(Commands.SWEEP, token, murphy.addr, amount));

        bytes memory route = plan.encode();
        rp.processRoute(route);

        assertEq(token.balanceOf(murphy.addr), amount);
        assertEq(token.balanceOf(address(rp)), 0);

        vm.expectRevert(Errors.InsufficientBalance.selector);
        rp.processRoute(route);
    }

    function test_sweep_ERC20() public {
        address token = WETH;
        uint256 amount = 1 ether;

        deal(token, address(rp), amount);

        // Encode sweep for ERC20 token
        plan = plan.add(abi.encodePacked(Commands.SWEEP, token, murphy.addr, amount));

        bytes memory route = plan.encode();
        rp.processRoute(route);

        assertEq(token.balanceOf(murphy.addr), amount);
        assertEq(token.balanceOf(address(rp)), 0);

        vm.expectRevert(Errors.InsufficientBalance.selector);
        rp.processRoute(route);
    }

    function assertBalance(address token, address recipient) internal view {
        assertGt(token.balanceOf(recipient), 0);
        assertEq(token.balanceOf(address(rp)), 0);
    }
}
