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

    function test_setPassword_UpdatesPassword() public {
        string memory newPassword = "my_secure_password";
        vm.prank(owner);
        passwordStore.setPassword(newPassword);
        vm.prank(owner);
        string memory storedPassword = passwordStore.getPassword();
        assertEq(storedPassword, newPassword);
    }

    function test_setPassword_NotOwnerCanSet() public {
        string memory attackerPassword = "hacked";
        vm.prank(nonOwner);
        passwordStore.setPassword(attackerPassword);
        vm.prank(owner);
        string memory storedPassword = passwordStore.getPassword();
        assertEq(storedPassword, attackerPassword);
    }

    function test_getPassword_WithOwner() public {
        string memory newPassword = "my_secure_password";
        vm.prank(owner);
        passwordStore.setPassword(newPassword);
        vm.prank(owner);
        string memory storedPassword = passwordStore.getPassword();
        assertEq(storedPassword, newPassword);
    }

    function test_getPassword_WithoutOwner() public {
        vm.expectRevert(PasswordStore.PasswordStore__NotOwner.selector);
        vm.prank(nonOwner);
        passwordStore.getPassword();
    }

    function test_passwordReadableViaStorageSlot() public {
        string memory password = "my_secure_password";
        vm.prank(owner);
        passwordStore.setPassword(password);

        bytes32 storedValue = vm.load(
            address(passwordStore),
            bytes32(uint256(1))
        );
        assertTrue(storedValue != bytes32(0));
    }
}
