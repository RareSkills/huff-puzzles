// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.17;

import "forge-std/Test.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";
import {NonMatchingSelectorHelper} from "./test-utils/NonMatchingSelectorHelper.sol";

interface Distributor {
    function distribute(address[] calldata) external payable;
}

contract DistributeTest is Test, NonMatchingSelectorHelper {
    address[16] precompiles_and_foundry_helper_addresses = [
        address(1),
        address(2),
        address(3),
        address(4),
        address(5),
        address(6),
        address(7),
        address(8),
        address(9),
        address(uint160(uint256(keccak256("hevm cheat code")))), // VM_ADDRESS
        0x000000000000000000636F6e736F6c652e6c6f67, // console address
        0x4e59b44847b379578588920cA78FbF26c0B4956C, // create2 factory
        0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38, // default sender
        0x5615dEB798BB3E4dFa0139dFa1b3D433Cc23b72f, // default test contract
        0xcA11bde05977b3631167028862bE2a173976CA11, // multicall3 address
        address(this)
    ];
    Distributor public distributor;

    function setUp() public {
        distributor = Distributor(HuffDeployer.config().deploy("Distributor"));
    }

    function testDistribute(uint256 value, address[] memory receivers) public {
        vm.deal(address(this), value);
        if (receivers.length == 0) vm.expectRevert();

        // foundry only accepts a max 2**16 of vm.assumes in a test run so assert the length of recievers * precompiles_and_foundry_helper_addresses is within the limit
        // also subtract 3 to account for the other assumes below
        vm.assume(receivers.length < (2 ** 16 / precompiles_and_foundry_helper_addresses.length) - 3);
        assume_not_precompile_or_foundry_helper_address(receivers);

        distributor.distribute{value: value}(receivers);
        for (uint256 i; i < receivers.length; ++i) {
            uint256 size;
            address receiver = receivers[i];
            assembly {
                size := extcodesize(receiver)
            }
            vm.assume(size == 0);
            assertGe(receiver.balance, value / receivers.length, "Wrong balance of receiver");
        }
    }

    /// @notice Test that a non-matching selector reverts
    function testNonMatchingSelector(bytes32 callData) public {
        bytes4[] memory func_selectors = new bytes4[](1);
        func_selectors[0] = Distributor.distribute.selector;

        bool success = nonMatchingSelectorHelper(func_selectors, callData, address(distributor));
        assert(!success);
    }

    function assume_not_precompile_or_foundry_helper_address(address[] memory addresses) private view {
        for (uint256 i; i < addresses.length; ++i) {
            for (uint256 j; j < precompiles_and_foundry_helper_addresses.length; ++j) {
                vm.assume(addresses[i] != precompiles_and_foundry_helper_addresses[j]);
            }
        }
    }
}
