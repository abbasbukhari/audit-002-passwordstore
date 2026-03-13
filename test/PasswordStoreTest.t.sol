// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {PasswordStore} from "../src/PasswordStore.sol";

contract PasswordStoreTest is Test {
    PasswordStore public passwordStore;
    address public owner;
    address public nonOwner;

    function setUp() public {
        owner = makeAddr("owner");
        nonOwner = makeAddr("nonOwner");

        vm.prank(owner);
        passwordStore = new PasswordStore();
    }

    // Write your tests below
    // Naming convention: test_[Function]_[BehaviorBeingTested]
}