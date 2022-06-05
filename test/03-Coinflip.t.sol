// // SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; // Latest solidity version

import "forge-std/Test.sol";
import "forge-std/Vm.sol";

import "../src/levels/03-Coinflip/CoinflipFactory.sol";
import "../src/levels/03-Coinflip/CoinflipAttack.sol";
import "../src/core/Ethernaut.sol";

contract CoinflipTest is Test {
    Ethernaut ethernaut;
    address attacker = address(1337);

    function setUp() public {
        ethernaut = new Ethernaut();
        // Sets an address' balance, (who, newBalance)
        vm.deal(attacker, 1 ether);
    }

    function testCoinflipHack() public {
        /////////////////
        // LEVEL SETUP //
        /////////////////

        CoinflipFactory coinflipFactory = new CoinflipFactory();
        ethernaut.registerLevel(coinflipFactory);
        vm.startPrank(attacker);
        address levelAddress = ethernaut.createLevelInstance(coinflipFactory);
        CoinflipAttack attackContract = new CoinflipAttack(levelAddress);
        Coinflip coinflipContract = Coinflip(payable(levelAddress));

        emit log_named_address("level addr", levelAddress);
        emit log_named_address("attackContract addr", address(attackContract));
        emit log_named_address(
            "coinflipContract addr",
            address(coinflipContract)
        );
        //////////////////
        // LEVEL ATTACK //
        //////////////////

        uint256 BLOCK_START = 100;
        vm.roll(BLOCK_START);

        for (uint256 i = BLOCK_START; i < BLOCK_START + 10; i++) {
            vm.roll(i + 1);
            attackContract.attack();
        }

        assertEq(coinflipContract.consecutiveWins(), 10);

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
