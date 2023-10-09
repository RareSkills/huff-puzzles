// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.19;

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

    function testDonations(uint256[] memory amounts) public {
        uint256 sum;
        for (uint256 i; i < amounts.length;) {
            vm.deal(address(this), amounts[i]);
            sum += amounts[i];
            (bool success,) = address(donations).call{value: amounts[i]}("");
            require(success, "call failed");
            assertEq(donations.donated(address(this)), sum, "Wrong expected donated balance");
            unchecked {
                if (amounts.length == ++i || sum + amounts[i] < sum) break;
            }
        }
    }
}
