// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {BaseTest} from "test/shared/BaseTest.sol";
import {Encoder} from "test/shared/Encoder.sol";

contract NativeWrapperTest is BaseTest {
    using SafeTransferLib for address;

    // ETH -> WETH
    function test_processNative_ETHToWETH() public {
        testProcess(ETH, WETH, Encoder.encodeNative(ETH, WETH));
    }

    // WETH -> ETH
    function test_processNative_WETHToETH() public {
        testProcess(WETH, ETH, Encoder.encodeNative(WETH, ETH));
    }

    // ETH -> rETH
    function test_processNative_Rocket_ETHToRETH() public {
        testProcess(ETH, RETH, Encoder.encodeRocket(ETH, RETH));
    }

    // ETH -> swETH
    function test_processNative_Swell_ETHToSWETH() public {
        testProcess(ETH, SWETH, Encoder.encodeSwell(ETH, SWETH));
    }

    // ETH -> wBETH
    function test_processNative_Binance_ETHToWBETH() public {
        testProcess(ETH, WBETH, Encoder.encodeBinance(ETH, WBETH));
    }

    // ETH -> ETHx
    function test_processNative_Stader_ETHToETHx() public {
        testProcess(ETH, ETHX, Encoder.encodeStader(ETH, ETHX));
    }

    // ETH -> osETH
    function test_processNative_StakeWise_ETHToOSETH() public {
        testProcess(ETH, OSETH, Encoder.encodeStakeWise(ETH, OSETH));
    }

    // ETH -> stETH
    function test_processNative_ETHToSTETH() public {
        testProcess(ETH, STETH, Encoder.encodeLido(ETH, STETH));
    }

    // ETH -> wstETH
    function test_processNative_ETHToWSTETH() public {
        testProcess(ETH, WSTETH, Encoder.encodeLido(ETH, WSTETH));
    }

    // stETH -> wstETH
    function test_processNative_STETHToWSTETH() public {
        testProcess(STETH, WSTETH, Encoder.encodeLido(STETH, WSTETH));
    }

    // wstETH -> stETH
    function test_processNative_WSTETHToSTETH() public {
        testProcess(WSTETH, STETH, Encoder.encodeLido(WSTETH, STETH));
    }

    // ETH -> eETH
    function test_processNative_EtherFi_ETHToEETH() public {
        testProcess(ETH, EETH, Encoder.encodeEtherFi(ETH, EETH));
    }

    // ETH -> weETH
    function test_processNative_EtherFi_ETHToWEETH() public {
        testProcess(ETH, WEETH, Encoder.encodeEtherFi(ETH, WEETH));
    }

    // eETH -> weETH
    function test_processNative_EtherFi_EETHToWEETH() public {
        testProcess(EETH, WEETH, Encoder.encodeEtherFi(EETH, WEETH));
    }

    // weETH -> eETH
    function test_processNative_EtherFi_WEETHToEETH() public {
        testProcess(WEETH, EETH, Encoder.encodeEtherFi(WEETH, EETH));
    }

    // ETH -> frxETH
    function test_processNative_Frax_ETHToFRXETH() public {
        testProcess(ETH, FRXETH, Encoder.encodeFrax(ETH, FRXETH));
    }

    // ETH -> sfrxETH
    function test_processNative_Frax_ETHToSFRXETH() public {
        testProcess(ETH, SFRXETH, Encoder.encodeFrax(ETH, SFRXETH));
    }

    // frxETH -> sfrxETH
    function test_processNative_Frax_FRXETHToSFRXETH() public {
        testProcess(FRXETH, SFRXETH, Encoder.encodeFrax(FRXETH, SFRXETH));
    }

    // sfrxETH -> frxETH
    function test_processNative_Frax_SFRXETHToFRXETH() public {
        testProcess(SFRXETH, FRXETH, Encoder.encodeFrax(SFRXETH, FRXETH));
    }

    // ETH -> OETH
    function test_processNative_Origin_WETHToOETH() public {
        testProcess(WETH, OETH, Encoder.encodeOrigin(WETH, OETH));
    }

    // ETH -> WOETH
    function test_processNative_Origin_WETHToWOETH() public {
        testProcess(WETH, WOETH, Encoder.encodeOrigin(WETH, WOETH));
    }

    // OETH -> WOETH
    function test_processNative_Origin_OETHToWOETH() public {
        testProcess(OETH, WOETH, Encoder.encodeOrigin(OETH, WOETH));
    }

    // WOETH -> OETH
    function test_processNative_Origin_WOETHToOETH() public {
        testProcess(WOETH, OETH, Encoder.encodeOrigin(WOETH, OETH));
    }

    // ETH -> ankrETH
    function test_processNative_Ankr_ETHToAnkrETH() public {
        testProcess(ETH, ANKRETH, Encoder.encodeAnkr(ETH, ANKRETH));
    }

    // ETH -> aETHb
    function test_processNative_Ankr_ETHToAETHb() public {
        testProcess(ETH, AETHB, Encoder.encodeAnkr(ETH, AETHB));
    }

    // ankrETH -> aETHb
    function test_processNative_Ankr_AnkrETHToAETHb() public {
        testProcess(ANKRETH, AETHB, Encoder.encodeAnkr(ANKRETH, AETHB));
    }

    // aETHb -> ankrETH
    function test_processNative_Ankr_AETHbToAnkrETH() public {
        testProcess(AETHB, ANKRETH, Encoder.encodeAnkr(AETHB, ANKRETH));
    }

    // ETH -> mETH
    function test_processNative_Mantle_ETHToMETH() public {
        testProcess(ETH, METH, Encoder.encodeMantle(ETH, METH));
    }

    // ETH -> cmETH
    function test_processNative_Mantle_ETHToCMETH() public {
        testProcess(ETH, CMETH, Encoder.encodeMantle(ETH, CMETH));
    }

    // mETH -> cmETH
    function test_processNative_Mantle_METHToCMETH() public {
        testProcess(METH, CMETH, Encoder.encodeMantle(METH, CMETH));
    }

    // ETH -> ezETH
    function test_processNative_Renzo_ETHToEZETH() public {
        testProcess(ETH, EZETH, Encoder.encodeRenzo(ETH, EZETH));
    }

    // stETH -> ezETH
    function test_processNative_Renzo_STETHToEZETH() public {
        testProcess(STETH, EZETH, Encoder.encodeRenzo(STETH, EZETH));
    }

    // wstETH -> pzETH
    function test_processNative_Renzo_WSTETHToPZETH() public {
        testProcess(WSTETH, PZETH, Encoder.encodeRenzo(WSTETH, PZETH));
    }

    // ETH -> pufETH
    function test_processNative_Puffer_ETHToPUFETH() public {
        testProcess(ETH, PUFETH, Encoder.encodePuffer(ETH, PUFETH));
    }

    // WETH -> pufETH
    function test_processNative_Puffer_WETHToPUFETH() public {
        testProcess(WETH, PUFETH, Encoder.encodePuffer(WETH, PUFETH));
    }

    // stETH -> pufETH
    function test_processNative_Puffer_STETHToPUFETH() public {
        testProcess(STETH, PUFETH, Encoder.encodePuffer(STETH, PUFETH));
    }

    // pufETH -> WETH
    function test_processNative_Puffer_PUFETHToWETH() public {
        testProcess(PUFETH, WETH, Encoder.encodePuffer(PUFETH, WETH));
    }

    function testProcess(address tokenIn, address tokenOut, bytes memory action) internal {
        uint256 amountIn = 10 ether;
        uint256 amountOutMin = 1;
        uint256 amountOut = tokenOut.balanceOf(cooper.addr);

        deal(tokenIn, address(rp), amountIn);

        plan = plan.addPath(action);
        plan = plan.finalizeSwap(cooper.addr, tokenIn, amountIn, amountOutMin);
        bytes memory route = plan.encode();

        vm.prank(murphy.addr);
        rp.processRoute(route);

        assertGe(amountOut = tokenOut.balanceOf(cooper.addr) - amountOut, amountOutMin);
        revertToState();
    }
}
