// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {IAllowanceTransfer} from "permit2/interfaces/IAllowanceTransfer.sol";
import {Commands} from "src/libraries/Commands.sol";
import {AssetType, Protocol} from "src/types/Enums.sol";

library Encoder {
    address internal constant ETH = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address internal constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address internal constant RETH_DEPOSIT = 0xDD3f50F8A6CafbE9b31a427582963f465E745AF8;
    address internal constant RETH = 0xae78736Cd615f374D3085123A210448E74Fc6393;

    address internal constant SWETH = 0xf951E335afb289353dc249e82926178EaC7DEd78;
    address internal constant WBETH = 0xa2E3356610840701BDf5611a53974510Ae27E2e1;

    address internal constant ETHX_DEPOSIT = 0xcf5EA1b38380f6aF39068375516Daf40Ed70D299;
    address internal constant ETHX = 0xA35b1B31Ce002FBF2058D22F30f95D405200A15b;

    address internal constant OSETH_DEPOSIT = 0xAC0F906E433d58FA868F936E8A43230473652885;
    address internal constant OSETH = 0xf1C9acDc66974dFB6dEcB12aA385b9cD01190E38;

    address internal constant STETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;
    address internal constant WSTETH = 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0;

    address internal constant EETH_DEPOSIT = 0x308861A430be4cce5502d0A12724771Fc6DaF216;
    address internal constant EETH = 0x35fA164735182de50811E8e2E824cFb9B6118ac2;
    address internal constant WEETH = 0xCd5fE23C85820F7B72D0926FC9b05b43E359b7ee;

    address internal constant FRXETH_DEPOSIT = 0xbAFA44EFE7901E04E39Dad13167D089C559c1138;
    address internal constant FRXETH = 0x5E8422345238F34275888049021821E8E08CAa1f;
    address internal constant SFRXETH = 0xac3E018457B222d93114458476f3E3416Abbe38F;

    address internal constant OETH_DEPOSIT = 0x39254033945AA2E4809Cc2977E7087BEE48bd7Ab;
    address internal constant OETH = 0x856c4Efb76C1D1AE02e20CEB03A2A6a08b0b8dC3;
    address internal constant WOETH = 0xDcEe70654261AF21C44c093C300eD3Bb97b78192;

    address internal constant ANKRETH_DEPOSIT = 0x84db6eE82b7Cf3b47E8F19270abdE5718B936670;
    address internal constant ANKRETH = 0xE95A203B1a91a908F9B9CE46459d101078c2c3cb;
    address internal constant AETHB = 0xD01ef7C0A5d8c432fc2d1a85c66cF2327362E5C6;

    address internal constant METH_DEPOSIT = 0xe3cBd06D7dadB3F4e6557bAb7EdD924CD1489E8f;
    address internal constant METH = 0xd5F7838F5C461fefF7FE49ea5ebaF7728bB0ADfa;
    address internal constant CMETH_DEPOSIT = 0xB6f7D38e3EAbB8f69210AFc2212fe82e0f1912b0;
    address internal constant CMETH = 0xE6829d9a7eE3040e1276Fa75293Bde931859e8fA;

    address internal constant EZETH_DEPOSIT = 0x74a09653A083691711cF8215a6ab074BB4e99ef5;
    address internal constant EZETH = 0xbf5495Efe5DB9ce00f80364C8B423567e58d2110;
    address internal constant PZETH = 0x8c9532a60E0E7C6BbD2B2c1303F63aCE1c3E9811;

    address internal constant PUFETH = 0xD9A442856C234a39a81a089C06451EBAa4306a72;

    function encodeV2Swap(address pool, address tokenOut, uint24 fee) internal pure returns (bytes memory result) {
        return abi.encodePacked(Protocol.UniswapV2, pool, tokenOut, fee);
    }

    function encodeV3Swap(address pool, address tokenOut, bytes4 callbackSelector)
        internal
        pure
        returns (bytes memory result)
    {
        return abi.encodePacked(Protocol.UniswapV3, pool, tokenOut, callbackSelector);
    }

    function encodeCurve(
        address pool,
        address tokenOut,
        uint8 i,
        uint8 j,
        bool isCrypto,
        bool useUnderlying,
        bool useEth
    ) internal pure returns (bytes memory result) {
        return abi.encodePacked(Protocol.Curve, pool, tokenOut, i, j, isCrypto, useUnderlying, useEth);
    }

    function encodeNative(address tokenIn, address tokenOut) internal pure returns (bytes memory result) {
        if (tokenIn == ETH && tokenOut == WETH) {
            return abi.encodePacked(Protocol.WETH, address(0), tokenOut, AssetType.ETH, AssetType.WETH);
        } else if (tokenIn == WETH && tokenOut == ETH) {
            return abi.encodePacked(Protocol.WETH, address(0), tokenOut, AssetType.WETH, AssetType.ETH);
        }
    }

    function encodeRocket(address tokenIn, address tokenOut) internal pure returns (bytes memory result) {
        if (tokenIn == ETH && tokenOut == RETH) {
            return abi.encodePacked(Protocol.Rocket, RETH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.LST);
        }
    }

    function encodeSwell(address tokenIn, address tokenOut) internal pure returns (bytes memory result) {
        if (tokenIn == ETH && tokenOut == SWETH) {
            return abi.encodePacked(Protocol.Swell, address(0), tokenOut, AssetType.ETH, AssetType.LST);
        }
    }

    function encodeBinance(address tokenIn, address tokenOut) internal pure returns (bytes memory result) {
        if (tokenIn == ETH && tokenOut == WBETH) {
            return abi.encodePacked(Protocol.Binance, address(0), tokenOut, AssetType.ETH, AssetType.LST);
        }
    }

    function encodeStader(address tokenIn, address tokenOut) internal pure returns (bytes memory result) {
        if (tokenIn == ETH && tokenOut == ETHX) {
            return abi.encodePacked(Protocol.Stader, ETHX_DEPOSIT, tokenOut, AssetType.ETH, AssetType.LST);
        }
    }

    function encodeStakeWise(address tokenIn, address tokenOut) internal pure returns (bytes memory result) {
        if (tokenIn == ETH && tokenOut == OSETH) {
            return abi.encodePacked(Protocol.StakeWise, OSETH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.LST);
        }
    }

    function encodeLido(address tokenIn, address tokenOut) internal pure returns (bytes memory result) {
        if (tokenIn == ETH && tokenOut == STETH) {
            return abi.encodePacked(Protocol.Lido, address(0), tokenOut, AssetType.ETH, AssetType.LST);
        } else if (tokenIn == ETH && tokenOut == WSTETH) {
            return abi.encodePacked(Protocol.Lido, address(0), tokenOut, AssetType.ETH, AssetType.WLST);
        } else if (tokenIn == STETH && tokenOut == WSTETH) {
            return abi.encodePacked(Protocol.Lido, address(0), tokenOut, AssetType.LST, AssetType.WLST);
        } else if (tokenIn == WSTETH && tokenOut == STETH) {
            return abi.encodePacked(Protocol.Lido, address(0), tokenOut, AssetType.WLST, AssetType.LST);
        }
    }

    function encodeEtherFi(address tokenIn, address tokenOut) internal pure returns (bytes memory result) {
        if (tokenIn == ETH && tokenOut == EETH) {
            return abi.encodePacked(Protocol.EtherFi, EETH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.LST);
        } else if (tokenIn == ETH && tokenOut == WEETH) {
            return abi.encodePacked(Protocol.EtherFi, EETH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.WLST);
        } else if (tokenIn == EETH && tokenOut == WEETH) {
            return abi.encodePacked(Protocol.EtherFi, address(0), tokenOut, AssetType.LST, AssetType.WLST);
        } else if (tokenIn == WEETH && tokenOut == EETH) {
            return abi.encodePacked(Protocol.EtherFi, address(0), tokenOut, AssetType.WLST, AssetType.LST);
        }
    }

    function encodeFrax(address tokenIn, address tokenOut) internal pure returns (bytes memory result) {
        if (tokenIn == ETH && tokenOut == FRXETH) {
            return abi.encodePacked(Protocol.Frax, FRXETH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.LST);
        } else if (tokenIn == ETH && tokenOut == SFRXETH) {
            return abi.encodePacked(Protocol.Frax, FRXETH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.WLST);
        } else if (tokenIn == FRXETH && tokenOut == SFRXETH) {
            return abi.encodePacked(Protocol.Frax, address(0), tokenOut, AssetType.LST, AssetType.WLST);
        } else if (tokenIn == SFRXETH && tokenOut == FRXETH) {
            return abi.encodePacked(Protocol.Frax, address(0), tokenOut, AssetType.WLST, AssetType.LST);
        }
    }

    function encodeOrigin(address tokenIn, address tokenOut) internal pure returns (bytes memory result) {
        if (tokenIn == WETH && tokenOut == OETH) {
            return abi.encodePacked(Protocol.Origin, OETH_DEPOSIT, tokenOut, AssetType.WETH, AssetType.LST);
        } else if (tokenIn == WETH && tokenOut == WOETH) {
            return abi.encodePacked(Protocol.Origin, OETH_DEPOSIT, tokenOut, AssetType.WETH, AssetType.WLST);
        } else if (tokenIn == OETH && tokenOut == WOETH) {
            return abi.encodePacked(Protocol.Origin, address(0), tokenOut, AssetType.LST, AssetType.WLST);
        } else if (tokenIn == WOETH && tokenOut == OETH) {
            return abi.encodePacked(Protocol.Origin, address(0), tokenOut, AssetType.WLST, AssetType.LST);
        }
    }

    function encodeAnkr(address tokenIn, address tokenOut) internal pure returns (bytes memory result) {
        if (tokenIn == ETH && tokenOut == ANKRETH) {
            return abi.encodePacked(Protocol.Ankr, ANKRETH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.LST);
        } else if (tokenIn == ETH && tokenOut == AETHB) {
            return abi.encodePacked(Protocol.Ankr, ANKRETH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.WLST);
        } else if (tokenIn == ANKRETH && tokenOut == AETHB) {
            return abi.encodePacked(Protocol.Ankr, address(0), tokenOut, AssetType.LST, AssetType.WLST);
        } else if (tokenIn == AETHB && tokenOut == ANKRETH) {
            return abi.encodePacked(Protocol.Ankr, address(0), tokenOut, AssetType.WLST, AssetType.LST);
        }
    }

    function encodeMantle(address tokenIn, address tokenOut) internal pure returns (bytes memory result) {
        if (tokenIn == ETH && tokenOut == METH) {
            return abi.encodePacked(Protocol.Mantle, METH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.LST);
        } else if (tokenIn == ETH && tokenOut == CMETH) {
            return abi.encodePacked(Protocol.Mantle, CMETH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.LRT);
        } else if (tokenIn == METH && tokenOut == CMETH) {
            return abi.encodePacked(Protocol.Mantle, CMETH_DEPOSIT, tokenOut, AssetType.LST, AssetType.LRT);
        }
    }

    function encodeRenzo(address tokenIn, address tokenOut) internal pure returns (bytes memory result) {
        if (tokenIn == ETH && tokenOut == EZETH) {
            return abi.encodePacked(Protocol.Renzo, EZETH_DEPOSIT, tokenOut, AssetType.ETH, AssetType.LRT);
        } else if (tokenIn == STETH && tokenOut == EZETH) {
            return abi.encodePacked(Protocol.Renzo, EZETH_DEPOSIT, tokenOut, AssetType.LST, AssetType.LRT);
        } else if (tokenIn == WSTETH && tokenOut == PZETH) {
            return abi.encodePacked(Protocol.Renzo, address(0), tokenOut, AssetType.WLST, AssetType.LRT);
        }
    }

    function encodePuffer(address tokenIn, address tokenOut) internal pure returns (bytes memory result) {
        if (tokenIn == ETH && tokenOut == PUFETH) {
            return abi.encodePacked(Protocol.Puffer, address(0), tokenOut, AssetType.ETH, AssetType.LRT);
        } else if (tokenIn == WETH && tokenOut == PUFETH) {
            return abi.encodePacked(Protocol.Puffer, address(0), tokenOut, AssetType.WETH, AssetType.LRT);
        } else if (tokenIn == STETH && tokenOut == PUFETH) {
            return abi.encodePacked(Protocol.Puffer, address(0), tokenOut, AssetType.LST, AssetType.LRT);
        } else if (tokenIn == PUFETH && tokenOut == WETH) {
            return abi.encodePacked(Protocol.Puffer, address(0), tokenOut, AssetType.LRT, AssetType.WETH);
        }
    }

    function encodeTransferFrom(address token, uint256 amount) internal pure returns (bytes memory result) {
        if (token == ETH || token == address(0)) return result;
        return abi.encodePacked(uint8(Commands.PERMIT2_TRANSFER_FROM), token, uint160(amount));
    }

    function encodeTransferFrom(IAllowanceTransfer.AllowanceTransferDetails memory details)
        internal
        pure
        returns (bytes memory result)
    {
        if (details.token == ETH || details.token == address(0)) return result;
        return abi.encodePacked(uint8(Commands.PERMIT2_TRANSFER_FROM), details.token, details.amount);
    }

    function encodeTransferFrom(IAllowanceTransfer.AllowanceTransferDetails[] memory details)
        internal
        pure
        returns (bytes memory result)
    {
        if (details.length == 0) return result;
        return abi.encodePacked(uint8(Commands.PERMIT2_TRANSFER_FROM_BATCH), b(abi.encode(details)));
    }

    function encodePermit(IAllowanceTransfer.PermitDetails memory details, uint256 sigDeadline, bytes memory signature)
        internal
        pure
        returns (bytes memory result)
    {
        if (details.token == ETH || details.token == address(0)) return result;
        uint256 word = (uint256(details.nonce) << 208) | (uint256(details.expiration) << 160) | uint256(details.amount);
        return abi.encodePacked(uint8(Commands.PERMIT2_PERMIT), details.token, word, sigDeadline, b(signature));
    }

    function encodePermit(
        IAllowanceTransfer.PermitDetails[] memory details,
        uint256 sigDeadline,
        bytes memory signature
    ) internal pure returns (bytes memory result) {
        if (details.length == 0) return result;
        return abi.encodePacked(uint8(Commands.PERMIT2_PERMIT_BATCH), b(abi.encode(details)), sigDeadline, b(signature));
    }

    function b(bytes memory data) internal pure returns (bytes memory) {
        return abi.encodePacked(data.length, data);
    }
}
