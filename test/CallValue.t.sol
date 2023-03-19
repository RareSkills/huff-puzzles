// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface CallValue {}

contract CallValueTest is Test {
    CallValue public callValue;

    function setUp() public {
        callValue = CallValue(HuffDeployer.config().deploy("CallValue"));
    }

    function testCallValue() public {
        vm.deal(address(this), 2 ether);
        (bool success, bytes memory retdata) = address(callValue).call{
            value: 1 ether
        }("");
        require(success, "call failed");
        assertEq(
            abi.decode(retdata, (uint256)),
            1 ether,
            "Expected retdata to be 1 ether"
        );

        (success, retdata) = address(callValue).call("");
        require(success, "call failed");
        assertEq(
            abi.decode(retdata, (uint256)),
            0,
            "Expected retdata to be 1 ether"
        );

        (success, retdata) = address(callValue).call{value: 0.5 ether}("");
        require(success, "call failed");
        assertEq(
            abi.decode(retdata, (uint256)),
            0.5 ether,
            "Expected retdata to be 1 ether"
        );
    }
}
