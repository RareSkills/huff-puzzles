// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface RevertString {
    function nonExistentFunction() external;
}

contract RevertStringTest is Test {
    RevertString public revertString;

    function setUp() public {
        revertString = RevertString(
            HuffDeployer.config().deploy("RevertString")
        );
    }

    function testRevertString() public {
        (bool success, bytes memory revertData) = address(revertString).call(
            ""
        );
        require(!success, "call expected to fail");
        assertEq(
            keccak256(bytes("Only Huff")),
            keccak256(abi.decode(revertData, (bytes)))
        );
    }
}
