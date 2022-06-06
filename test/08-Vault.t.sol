// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; // Latest solidity version

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import "../src/levels/08-Vault/VaultFactory.sol";
import "../src/core/Ethernaut.sol";

contract VaultTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        // Sets an address' balance, (who, newBalance)
        vm.deal(attacker, 1 ether);
    }

    function testVaultHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        VaultFactory vaultFactory = new VaultFactory();
        ethernaut.registerLevel(vaultFactory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(vaultFactory);
        Vault vaultContract = Vault(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        //////////////////////
        // LEVEL SUBMISSION //
        //////////////////////

        bool levelSuccessfullyPassed = ethernaut.submitLevelInstance(
            payable(levelAddress)
        );
        vm.stopPrank();
        assert(levelSuccessfullyPassed);
    }
}
