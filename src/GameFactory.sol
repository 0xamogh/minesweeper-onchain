// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./Game.sol"

contract GameFactory {
    uint256 public currentRound;
    uint256 public timeTillNextRound;
    uint256 public numberOfGamesInCurrentRound;

    function createGame() public {
        Game game = new Game(msg.sender);
    }


    function setNumber(uint256 newNumber) public {
        number = newNumber;
    }

    function increment() public {
        number++;
    }
}
