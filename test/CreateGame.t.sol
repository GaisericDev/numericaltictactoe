// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/GameFactory.sol";

// Act as certain address, how to make this work so we can pass tx.origin == msg.sender ? 
// https://stackoverflow.com/questions/73670446/foundry-call-smart-contract-from-with-eoa-address
interface CheatCodes {
    function prank(address) external;    
}

contract CreateGame is Test {
    GameFactory public gameFactory;
    CheatCodes cheatCodes;
    address p1 = address(0x35524A1a02D6C89C8FceAd21644cB61b032BD3DE);
    address p2 = address(0x35524a1A02d6C89C8FCEAD21644CB61B032Bd3Df);

    function setUp() public {
        gameFactory = new GameFactory();
        cheatCodes = CheatCodes(HEVM_ADDRESS);
        // Create a game of board size 3
        gameFactory.createPvP(3);
    }

    // P1 creates a game with board size n = 0
    function testFailCreateGame0() public {
        // address is now the caller
        cheatCodes.prank(p1);
        uint8 boardSize = 0;
        gameFactory.createPvP(boardSize);
    }
    // P1 creates a game with board size n = 1
    function testFailCreateGame1() public {
        // address is now the caller
        cheatCodes.prank(p1);
        uint8 boardSize = 1;
        gameFactory.createPvP(boardSize);
    }
    // P1 creates a game with board size n = 2
    function testFailCreateGame2() public {
        // address is now the caller
        cheatCodes.prank(p1);
        uint8 boardSize = 2;
        gameFactory.createPvP(boardSize);
    }
    // P1 creates a game with board size n > 2
    function testCreateGame(uint8 boardSize) public {
        // address is now the caller
        cheatCodes.prank(p1);
        vm.assume(boardSize > 2);
        gameFactory.createPvP(boardSize);
    }
}