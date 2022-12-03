// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./Game.sol";

contract GameFactory {
    address[] public allGames;
    uint256[] private nextCoordinates;
    uint256 public constant NUM_MINES = 10;

    function startNewGame() public returns (address){
        // Initialize game using previous coordinates
        Game nextGame = new Game(nextCoordinates);
        allGames.push(address(nextGame));
        return address(nextGame);
    }

    // function handleCoordinates(uint256[] memory coordinates) internal returns (uint256[] memory){
    //     require(coordinates.length == NUM_MINES*2, "Game : Incorrect number of mines generated");
    //     for(uint8 i = 0; i < coordinates.length; i++){
    //         // limit the max number to be 80
    //         nextCoordinates[i] = coordinates[i] % 81;
    //     }
    //     return nextCoordinates;
    // }
}
