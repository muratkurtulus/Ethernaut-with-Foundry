// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; // Latest solidity version

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import "../src/levels/04-Telephone/TelephoneFactory.sol";
import "../src/levels/04-Telephone/TelephoneAttack.sol";
import "../src/core/Ethernaut.sol";

contract TelephoneTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        // Sets an address' balance, (who, newBalance)
        vm.deal(attacker, 1 ether);
    }

    function testTelephoneHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        TelephoneFactory telephoneFactory = new TelephoneFactory();
        ethernaut.registerLevel(telephoneFactory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(telephoneFactory);
        TelephoneAttack attackContract = new TelephoneAttack(levelAddress);
        Telephone telephoneContract = Telephone(payable(levelAddress));

        //////////////////
        // LEVEL ATTACK //
        //////////////////

        emit log_named_address("tx.origin", tx.origin);
        emit log_named_address("msg.sender", attacker);
        attackContract.attack();

        assertEq(telephoneContract.owner(), attacker);

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
