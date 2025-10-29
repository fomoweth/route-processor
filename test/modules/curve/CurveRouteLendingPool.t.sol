// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {BaseTest} from "test/shared/BaseTest.sol";

contract CurveRouteLendingPoolTest is BaseTest {
    using SafeTransferLib for address;

    address internal constant A3CRV = 0xDeBF20617708857ebe4F679508E7b7863a8A8EeE; // aDAI/aUSDC/aUSDT
    address internal constant LENDING_POOL = 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9;
    address internal constant ADAI = 0x028171bCA77440897B824Ca71D1c56caC55b68A3;
    address internal constant AUSDC = 0xBcca60bB61934080951369a648Fb03DF4F96263C;
    address internal constant AUSDT = 0x3Ed3B47Dd13EC9a98b44e6204A523E766B225811;

    address internal constant C2CRV = 0xA2B47E3D5c44877cca798226B7B8118F9BFb7A56; // cDAI/cUSDC
    address internal constant CDAI = 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643;
    address internal constant CUSDC = 0x39AA39c021dfbaE8faC545936693aC917d5E7563;

    function test_processCurveOnLendingPool_ADAI_AUSDC() public {
        address token = DAI;
        address tokenIn = ADAI;
        address tokenOut = AUSDC;

        depositATokenFor(token, 10000 ether, address(rp));

        plan = plan.addCurve(A3CRV, tokenOut, 0, 1, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnLendingPool_ADAI_AUSDT() public {
        address token = DAI;
        address tokenIn = ADAI;
        address tokenOut = AUSDT;

        depositATokenFor(token, 10000 ether, address(rp));

        plan = plan.addCurve(A3CRV, tokenOut, 0, 2, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnLendingPool_AUSDC_ADAI() public {
        address token = USDC;
        address tokenIn = AUSDC;
        address tokenOut = ADAI;

        depositATokenFor(token, 10000e6, address(rp));

        plan = plan.addCurve(A3CRV, tokenOut, 1, 0, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnLendingPool_AUSDC_AUSDT() public {
        address token = USDC;
        address tokenIn = AUSDC;
        address tokenOut = AUSDT;

        depositATokenFor(token, 10000e6, address(rp));

        plan = plan.addCurve(A3CRV, tokenOut, 1, 2, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnLendingPool_AUSDT_ADAI() public {
        address token = USDT;
        address tokenIn = AUSDT;
        address tokenOut = ADAI;

        depositATokenFor(token, 10000e6, address(rp));

        plan = plan.addCurve(A3CRV, tokenOut, 2, 0, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnLendingPool_AUSDT_AUSDC() public {
        address token = USDT;
        address tokenIn = AUSDT;
        address tokenOut = AUSDC;

        depositATokenFor(token, 10000e6, address(rp));

        plan = plan.addCurve(A3CRV, tokenOut, 2, 1, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnLendingPool_DAI_USDC_AAVE() public {
        address tokenIn = DAI;
        address tokenOut = USDC;

        deal(tokenIn, address(rp), 10000 ether);

        plan = plan.addCurve(A3CRV, tokenOut, 0, 1, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnLendingPool_DAI_USDT_AAVE() public {
        address tokenIn = DAI;
        address tokenOut = USDT;

        deal(tokenIn, address(rp), 10000 ether);

        plan = plan.addCurve(A3CRV, tokenOut, 0, 2, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnLendingPool_USDC_DAI_AAVE() public {
        address tokenIn = USDC;
        address tokenOut = DAI;

        deal(tokenIn, address(rp), 10000e6);

        plan = plan.addCurve(A3CRV, tokenOut, 1, 0, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnLendingPool_USDC_USDT_AAVE() public {
        address tokenIn = USDC;
        address tokenOut = USDT;

        deal(tokenIn, address(rp), 10000e6);

        plan = plan.addCurve(A3CRV, tokenOut, 1, 2, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnLendingPool_USDT_DAI_AAVE() public {
        address tokenIn = USDT;
        address tokenOut = DAI;

        deal(tokenIn, address(rp), 10000e6);

        plan = plan.addCurve(A3CRV, tokenOut, 2, 0, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnLendingPool_USDT_USDC_AAVE() public {
        address tokenIn = USDT;
        address tokenOut = USDC;

        deal(tokenIn, address(rp), 10000e6);

        plan = plan.addCurve(A3CRV, tokenOut, 2, 1, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnLendingPool_CDAI_CUSDC() public {
        address token = DAI;
        address tokenIn = CDAI;
        address tokenOut = CUSDC;

        depositCTokenFor(tokenIn, token, 10000 ether, address(rp));

        plan = plan.addCurve(C2CRV, tokenOut, 0, 1, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnLendingPool_CUSDC_CDAI() public {
        address token = USDC;
        address tokenIn = CUSDC;
        address tokenOut = CDAI;

        depositCTokenFor(tokenIn, token, 10000e6, address(rp));

        plan = plan.addCurve(C2CRV, tokenOut, 1, 0, false, false, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnLendingPool_DAI_USDC_COMP() public {
        address tokenIn = DAI;
        address tokenOut = USDC;

        deal(tokenIn, address(rp), 10000 ether);

        plan = plan.addCurve(C2CRV, tokenOut, 0, 1, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function test_processCurveOnLendingPool_USDC_DAI_COMP() public {
        address tokenIn = USDC;
        address tokenOut = DAI;

        deal(tokenIn, address(rp), 10000e6);

        plan = plan.addCurve(C2CRV, tokenOut, 1, 0, false, true, false);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, CONTRACT_BALANCE, 1);

        rp.processRoute(plan.encode());
        assertGt(tokenOut.balanceOf(cooper.addr), 0);
    }

    function depositATokenFor(address token, uint256 amount, address recipient) internal {
        deal(token, address(this), amount);
        token.forceApprove(LENDING_POOL, amount);

        // 0xe8eda9df: deposit(address,uint256,address,uint16)
        (bool success,) = LENDING_POOL.call(abi.encodeWithSelector(0xe8eda9df, token, amount, recipient, uint16(0)));
        require(success);
    }

    function depositCTokenFor(address cToken, address token, uint256 amount, address recipient) internal {
        deal(token, address(this), amount);
        token.forceApprove(cToken, amount);

        // 0xa0712d68: mint(uint256)
        (bool success, bytes memory returndata) = cToken.call(abi.encodeWithSelector(0xa0712d68, amount));
        require(success && abi.decode(returndata, (uint256)) == 0);

        cToken.safeTransfer(recipient, cToken.balanceOf(address(this)));
    }
}
