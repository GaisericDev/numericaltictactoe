// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/GameFactory.sol";

contract CreateGame is Test {
    GameFactory public gameFactory;
    address p1 = address(0x35524A1a02D6C89C8FceAd21644cB61b032BD3DE);
    address p2 = address(0x35524a1A02d6C89C8FCEAD21644CB61B032Bd3Df);
    address p3 = address(0x35524A1A02d6c89C8fceAd21644cB61b032bd3dD);

    function setUp() public {
        gameFactory = new GameFactory();
        // Create a game of board size 3
        vm.prank(p1, p1); // should only be valid for creating the game and not subsequent calls
        gameFactory.createPvP(3); // game created by p1
        // P2 joins P1 game
        vm.prank(p2, p2);
        gameFactory.join(0);
    }

    // Assert P1 Turn
    function testP1Turn() public {
        // turn == false => p1 turn
        // turn == true => p2 turn
        bool turn = gameFactory.games[0].turn;
        assertEq(turn, false);
     }
}