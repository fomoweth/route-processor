// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {Commands} from "src/libraries/Commands.sol";

using Planner for Plan global;

struct Plan {
    bytes[] actions;
    bytes[] path;
}

library Planner {
    function init() internal pure returns (Plan memory) {
        return Plan({actions: new bytes[](0), path: new bytes[](0)});
    }

    function add(Plan memory plan, bytes memory action) internal pure returns (Plan memory) {
        if (action.length != 0) {
            bytes[] memory actions = new bytes[](plan.actions.length + 1);

            for (uint256 i; i < actions.length - 1; ++i) {
                actions[i] = plan.actions[i];
            }

            actions[actions.length - 1] = action;
            plan.actions = actions;
        }

        return plan;
    }

    function addPath(Plan memory plan, bytes memory action) internal pure returns (Plan memory) {
        if (action.length != 0) {
            bytes[] memory path = new bytes[](plan.path.length + 1);

            for (uint256 i; i < path.length - 1; ++i) {
                path[i] = plan.path[i];
            }

            path[path.length - 1] = action;
            plan.path = path;
        }

        return plan;
    }

    function finalizeSwap(Plan memory plan, address recipient, address tokenIn, uint256 amountIn, uint256 amountOutMin)
        internal
        pure
        returns (Plan memory)
    {
        uint8 n = uint8(plan.path.length);
        require(n != 0);

        bytes[] memory path = plan.path;
        plan.path = new bytes[](0);

        bytes memory action = abi.encodePacked(uint8(Commands.SWAP), recipient, tokenIn, amountIn, amountOutMin, n);
        for (uint256 i = 0; i < n; ++i) {
            action = bytes.concat(action, path[i]);
        }

        return plan.add(action);
    }

    function encode(Plan memory plan) internal pure returns (bytes memory route) {
        uint256 n = plan.actions.length;
        require(n != 0 && plan.path.length == 0);

        for (uint256 i = 0; i < n; ++i) {
            route = bytes.concat(route, plan.actions[i]);
        }
    }
}
