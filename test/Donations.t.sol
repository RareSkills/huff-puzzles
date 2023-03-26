// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {HuffConfig} from "foundry-huff/HuffConfig.sol";
import {HuffDeployer} from "foundry-huff/HuffDeployer.sol";

interface Donations {
    function donated(address user) external view returns (uint256);
}

contract DonationsTest is Test {
    Donations public donations;

    function setUp() public {
        donations = Donations(HuffDeployer.config().deploy("Donations"));
    }

    function testDonations() public {
        // first party
        vm.deal(address(this), 1 ether);
        (bool success, ) = address(donations).call{value: 0.5 ether}("");
        require(success, "call failed");
        assertEq(
            donations.donated(address(this)),
            0.5 ether,
            "expected donated balance of address(this) to be 0.5 ether"
        );
        (success, ) = address(donations).call{value: 0.2 ether}("");
        require(success, "call failed");
        assertEq(
            donations.donated(address(this)),
            0.7 ether,
            "expected donated balance of address(this) to be 0.7 ether"
        );

        // second party
        startHoax(address(0xCAFE), 1 ether);
        (success, ) = address(donations).call{value: 0.5 ether}("");
        require(success, "call failed");
        assertEq(
            donations.donated(address(0xCAFE)),
            0.5 ether,
            "expected donated balance of address(0xCAFE) to be 0.5 ether"
        );
        (success, ) = address(donations).call{value: 0.3 ether}("");
        require(success, "call failed");
        assertEq(
            donations.donated(address(0xCAFE)),
            0.8 ether,
            "expected donated balance of address(0xCAFE) to be 0.8 ether"
        );

        // try send 0
        (success, ) = address(donations).call{value: 0 ether}("");
        require(success, "call failed");
        assertEq(
            donations.donated(address(0xCAFE)),
            0.8 ether,
            "expected donated balance of address(0xCAFE) to be 0.8 ether"
        );
    }
}
