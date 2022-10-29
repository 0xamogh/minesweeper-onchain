// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";

struct Coordinates {
    int256 x; 
    int256 y; 
}

contract Game is Ownable {
    address owner;
    uint256 roundNumber;
    uint256 gameNumber;
    Coordinates[] mines;
    
    constructor(address _owner){
        owner = _owner;
    }

}