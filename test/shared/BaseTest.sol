// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Test} from "forge-std/Test.sol";
import {stdStorage, StdStorage} from "forge-std/StdStorage.sol";
import {SafeTransferLib} from "src/libraries/SafeTransferLib.sol";
import {RouteProcessor} from "src/RouteProcessor.sol";
import {Constants} from "test/shared/Constants.sol";
import {Planner, Plan} from "test/shared/Planner.sol";

abstract contract BaseTest is Test, Constants {
    using stdStorage for StdStorage;
    using SafeTransferLib for address;

    uint256 internal snapshotId = MAX_UINT256;

    RouteProcessor internal rp;

    Account internal cooper;
    Account internal murphy;

    Plan internal plan;

    modifier impersonate(address account) {
        vm.startPrank(account);
        _;
        vm.stopPrank();
    }

    function setUp() public virtual {
        vm.createSelectFork("mainnet", FORK_BLOCK);

        rp = new RouteProcessor();

        cooper = makeAccount("cooper");
        murphy = makeAccount("murphy");

        plan = Planner.init();

        revertToState();
    }

    function revertToState() internal {
        if (snapshotId != MAX_UINT256) vm.revertToState(snapshotId);
        snapshotId = vm.snapshotState();
    }

    function deal(address token, address account, uint256 value, bool adjust) internal virtual override {
        if (token == ETH || token == address(0)) {
            vm.deal(account, value);
        } else if (token == STETH) {
            // 0xf5eb42dc: sharesOf(address)
            // 0xd5002f2e: getTotalShares()
            deal(token, account, value, adjust, 0xf5eb42dc, 0xd5002f2e);
        } else if (token == EETH) {
            // 0xce7c2ac2: shares(address)
            // 0x3a98ef39: totalShares()
            deal(token, account, value, adjust, 0xce7c2ac2, 0x3a98ef39);
        } else if (token == AETHB) {
            // 0x9bbb02da: lockedSharesOf(address)
            deal(token, account, value, false, 0x9bbb02da, bytes4(0));
        } else if (token == OETH) {
            bytes32 creditsSlot = keccak256(abi.encode(account, uint256(157)));
            uint256 balancePrior = token.balanceOf(account);

            // 0x7a46a9c5: rebasingCreditsPerTokenHighres()
            (, bytes memory returndata) = token.staticcall(abi.encodeWithSelector(0x7a46a9c5));
            uint256 cpt = abi.decode(returndata, (uint256));
            uint256 credits = value * cpt / 1e18;

            vm.store(token, creditsSlot, bytes32(credits));
            assertEq(token.balanceOf(account), value);

            if (adjust) {
                uint256 totalSupply = token.totalSupply();

                if (value < balancePrior) {
                    totalSupply -= (balancePrior - value);
                } else {
                    totalSupply += (value - balancePrior);
                }

                bytes32 totalSupplySlot = bytes32(uint256(154));
                vm.store(token, totalSupplySlot, bytes32(totalSupply));
            }
        } else {
            // 0x70a08231: balanceOf(address)
            // 0x18160ddd: totalSupply()
            deal(token, account, value, adjust, 0x70a08231, 0x18160ddd);
        }
    }

    function deal(
        address token,
        address account,
        uint256 value,
        bool adjust,
        bytes4 balanceOfSelector,
        bytes4 totalSupplySelector
    ) internal virtual {
        (, bytes memory returndata) = token.staticcall(abi.encodeWithSelector(balanceOfSelector, account));
        uint256 balancePrior = abi.decode(returndata, (uint256));

        stdstore.target(token).sig(balanceOfSelector).with_key(account).checked_write(value);

        if (adjust) {
            if (token == WETH) {
                if (value < balancePrior) {
                    vm.deal(token, token.balance - (balancePrior - value));
                } else {
                    vm.deal(token, token.balance + (value - balancePrior));
                }
            } else {
                (, returndata) = token.staticcall(abi.encodeWithSelector(totalSupplySelector));
                uint256 totalSupply = abi.decode(returndata, (uint256));

                if (value < balancePrior) {
                    totalSupply -= (balancePrior - value);
                } else {
                    totalSupply += (value - balancePrior);
                }

                stdstore.target(token).sig(totalSupplySelector).checked_write(totalSupply);
            }
        }
    }

    function scale(address token, uint256 amount) internal view returns (uint256) {
        return amount / (10 ** (18 - token.decimals()));
    }

    function random(address[] memory array, uint256 seed) internal pure returns (address) {
        return array[seed % array.length];
    }

    function random(uint256[] memory array, uint256 seed) internal pure returns (uint256) {
        return array[seed % array.length];
    }
}
