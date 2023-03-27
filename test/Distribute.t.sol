// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface Distributor {
    function distribute(address[] calldata) external payable;
}

contract DistributeTest is Test, NonMatchingSelectorHelper {
    Distributor public distributor;

    function setUp() public {
        distributor = Distributor(HuffDeployer.config().deploy("Distributor"));
    }

    function testDistribute() public {
        address[] memory addresses = new address[](4);
        addresses[0] = address(0xBab);
        addresses[1] = address(0xBeb);
        addresses[2] = address(0xBed);
        addresses[3] = address(0xBad);

        vm.deal(address(this), 4 ether);
        distributor.distribute{value: 4 ether}(addresses);

        assertEq(
            addresses[0].balance,
            1 ether,
            "balance of address 0xBab is not 1 ether"
        );
        assertEq(
            addresses[1].balance,
            1 ether,
            "balance of address 0xBeb is not 1 ether"
        );
        assertEq(
            addresses[2].balance,
            1 ether,
            "balance of address 0xBed is not 1 ether"
        );
        assertEq(
            addresses[3].balance,
            1 ether,
            "balance of address 0xBad is not 1 ether"
        );

        assertEq(
            address(distributor).balance,
            0,
            "balance of distribute contract is not 0 ether"
        );
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](1);
        func_selectors[0] = Distributor.distribute.selector;

        bool success = nonMatchingSelectorHelper(
            func_selectors,
            callData,
            address(distributor)
        );
        assert(!success);
    }
}
