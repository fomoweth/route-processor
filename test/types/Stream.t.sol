// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {Protocol} from "src/types/Enums.sol";
import {Stream, createStream} from "src/types/Stream.sol";

contract StreamTest is Test {
    function test_fuzz_parseProtocol(uint8 x) public pure {
        vm.assume(x <= uint8(type(Protocol).max));
        Stream s = createStream(abi.encodePacked(Protocol(x)));
        assertEq(uint8(s.parseProtocol()), x);
    }

    function test_fuzz_parseAddress(address x) public pure {
        Stream s = createStream(abi.encodePacked(x));
        assertEq(s.parseAddress(), x);
    }

    function test_fuzz_parseUint8(uint8 x) public pure {
        Stream s = createStream(abi.encodePacked(x));
        assertEq(s.parseUint8(), x);
    }

    function test_fuzz_parseUint16(uint16 x) public pure {
        Stream s = createStream(abi.encodePacked(x));
        assertEq(s.parseUint16(), x);
    }

    function test_fuzz_parseUint24(uint24 x) public pure {
        Stream s = createStream(abi.encodePacked(x));
        assertEq(s.parseUint24(), x);
    }

    function test_fuzz_parseUint48(uint48 x) public pure {
        Stream s = createStream(abi.encodePacked(x));
        assertEq(s.parseUint48(), x);
    }

    function test_fuzz_parseUint128(uint128 x) public pure {
        Stream s = createStream(abi.encodePacked(x));
        assertEq(s.parseUint128(), x);
    }

    function test_fuzz_parseUint160(uint160 x) public pure {
        Stream s = createStream(abi.encodePacked(x));
        assertEq(s.parseUint160(), x);
    }

    function test_fuzz_parseUint256(uint256 x) public pure {
        Stream s = createStream(abi.encodePacked(x));
        assertEq(s.parseUint256(), x);
    }

    function test_fuzz_parseInt256(int256 x) public pure {
        Stream s = createStream(abi.encodePacked(x));
        assertEq(s.parseInt256(), x);
    }

    function test_fuzz_parseBytes4(bytes4 x) public pure {
        Stream s = createStream(abi.encodePacked(x));
        assertEq(s.parseBytes4(), x);
    }

    function test_fuzz_parseBytes32(bytes32 x) public pure {
        Stream s = createStream(abi.encodePacked(x));
        assertEq(s.parseBytes32(), x);
    }

    function test_fuzz_parseBytes(bytes memory x) public pure {
        Stream s = createStream(abi.encodePacked(x.length, x));
        assertEq(s.parseBytes(), x);
    }
}
