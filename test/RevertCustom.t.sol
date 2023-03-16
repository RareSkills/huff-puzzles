// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface RevertCustom {
    function nonExistentFunction() external;
}

contract RevertCustomTest is Test {
    RevertCustom public revertCustom;

    function setUp() public {
        revertCustom = RevertCustom(
            HuffDeployer.config().deploy("RevertCustom")
        );
    }

    function testRevertCustom() public {
        vm.expectRevert(bytes4(keccak256("OnlyHuff()")));
        revertCustom.nonExistentFunction();
    }
}
