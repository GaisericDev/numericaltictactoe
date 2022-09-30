// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/GameFactory.sol";

contract CreateGame is Test {
    GameFactory public gameFactory;
    address p1 = address(0x35524A1a02D6C89C8FceAd21644cB61b032BD3DE);
    address p2 = address(0x35524a1A02d6C89C8FCEAD21644CB61B032Bd3Df);

    function setUp() public {
        gameFactory = new GameFactory();
        vm.prank(p1, p1); // should only be valid for creating the game and not subsequent calls
        // Create a game of board size 3
        gameFactory.createPvP(3);
    }

    // P1 creates a game with board size n = 0
    function testFailCreateGame0() public {
        // address is now the caller
        vm.prank(p1, p1);
        uint8 boardSize = 0;
        gameFactory.createPvP(boardSize);
    }
    // P1 creates a game with board size n = 1
    function testFailCreateGame1() public {
        // address is now the caller
        vm.prank(p1, p1);
        uint8 boardSize = 1;
        gameFactory.createPvP(boardSize);
    }
    // P1 creates a game with board size n = 2
    function testFailCreateGame2() public {
        // address is now the caller
        vm.prank(p1, p1);
        uint8 boardSize = 2;
        gameFactory.createPvP(boardSize);
    }
    // P1 creates a game with board size n > 2
    function testCreateGame(uint8 boardSize) public {
        // address is now the caller
        vm.prank(p1, p1);
        vm.assume(boardSize > 2);
        gameFactory.createPvP(boardSize);
    }

    // P1 calls P2 to create a game, so msg.sender != tx.origin
    function testExpectRevertCreateGame() public{
        vm.prank(p2, p1);
        vm.expectRevert(abi.encodePacked("Not a valid player"));
        gameFactory.createPvP(3);
    }
}