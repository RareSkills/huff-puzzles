// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface RevertString {}

contract RevertStringTest is Test {
    RevertString public revertString;

    function setUp() public {
        revertString = RevertString(HuffDeployer.config().deploy("RevertString"));
    }

    function testRevertString() public {
        (bool success, bytes memory revertData) = address(revertString).call("");
        require(!success, "call expected to fail");
        assertEq(
            keccak256(bytes("Only Huff")),
            keccak256(abi.decode(revertData, (bytes))),
            "Expected the call to revert with custom error 'Only Huff' but it didn't "
        );
    }
}
