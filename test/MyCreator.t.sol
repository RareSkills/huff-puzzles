// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import {HuffDeployer, HuffConfig} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface MyCreator {
    function getMyCreator() external returns (address);
}

contract MyCreatorTest is Test, NonMatchingSelectorHelper {
    MyCreator public myCreator;
    HuffConfig public config;

    function setUp() public {
        config = HuffDeployer.config();
        myCreator = MyCreator(config.deploy("MyCreator"));
    }

    function testMyCreator() public {
        address returnedCreator = myCreator.getMyCreator();

        assertEq(
            returnedCreator,
            address(config),
            string.concat(
                "The returned creator address differs from the correct: ",
                vm.toString(returnedCreator),
                " != ",
                vm.toString(address(config))
            )
        );
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](1);
        func_selectors[0] = MyCreator.getMyCreator.selector;

        bool success = nonMatchingSelectorHelper(func_selectors, callData, address(myCreator));
        assert(!success);
    }
}
