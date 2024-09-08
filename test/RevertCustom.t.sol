// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface RevertCustom {}

contract RevertCustomTest is Test {
    RevertCustom public revertCustom;

    function setUp() public {
        revertCustom = RevertCustom(HuffDeployer.config().deploy("RevertCustom"));
    }

    function testRevertCustom() public {
        (bool success, bytes memory revertMessage) = address(revertCustom).call("");
        assertEq(success, false, "Call expected to revert but it didn't");
        assertEq(
            keccak256(abi.encode(bytes4(revertMessage))),
            keccak256(abi.encode(bytes4(keccak256("OnlyHuff()")))),
            "Expected the call to revert with custom error 'OnlyHuff()' but it didn't "
        );
    }
}
