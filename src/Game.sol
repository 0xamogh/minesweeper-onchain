// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./GameFactory.sol";
import "hardhat/console.sol";

contract Game is Ownable {

    struct Coordinates {
        uint256 x; 
        uint256 y; 
    }

     enum CoordinateStatus {
        Zero,
        One,
        Two,
        Three,
        Four,
        Five,
        Six,
        Seven,
        Eight,
        Mine,
        Untouched
     }

     enum GameStatus {
        NotStarted,
        Ongoing,
        Ended
     }

    uint256 immutable public BOARDLENGTH = 9;
    uint256 public constant GAME_TIME = 5 minutes;
    uint256 public constant NUM_MINES = 10;

    event GameEnded(bool playerWins, uint256 gameId);

    Game private previousGame;
     uint256 public gameId;
     uint256 private nonMineCount;
     uint256 private numMines;
     uint256 public startTime;
     uint256 public timeTaken;
     GameStatus public gameStatus;

    CoordinateStatus[][] public playerBoard;
    CoordinateStatus[][] public realBoard;

    mapping(uint256 => Coordinates) private mines;
    // uint256[] private randomNumbers;

    constructor(uint256[] memory coordinates){
        // generateCoordinates(coordinates, NUM_MINES);
        initializeGame();
    }

    function initializeGame() internal {
        nonMineCount = BOARDLENGTH*BOARDLENGTH - NUM_MINES;
        
        playerBoard = new CoordinateStatus[][](BOARDLENGTH);
        realBoard = new CoordinateStatus[][](BOARDLENGTH);
        for(uint256 i = 0; i < BOARDLENGTH;i++){
            console.log("this is fucking up");
            playerBoard[i] = new CoordinateStatus[](BOARDLENGTH); 
            realBoard[i] = new CoordinateStatus[](BOARDLENGTH); 
        }
        
        for(uint256 i = 0; i < NUM_MINES;i++){
            uint8 x = uint8(keccak256(abi.encodePacked(now, i))) % BOARDLENGTH;
            uint8 y = uint8(keccak256(abi.encodePacked(now, i, x))) % BOARDLENGTH;
            realBoard[mines[i].x][mines[i].y] = CoordinateStatus.Mine; 
        }
        console.log("reaches here");
        intializeBoards();
        startTime = block.timestamp;
        gameStatus = GameStatus.NotStarted;
    }

    function intializeBoards() internal {
        for(uint256 i = 0; i < BOARDLENGTH; i++){
            for(uint256 j = 0; j < BOARDLENGTH; j++){
                console.log("iteration i j", i,j);
                playerBoard[i][j] = CoordinateStatus.Untouched;

                if(realBoard[i][j] == CoordinateStatus.Mine){
                    continue;
                }
                console.log("initializeBoards");

                uint256 counter = 0;

                counter =  isMine(int256(i)-1,int256(j)-1) ? counter + 1 : counter; 
                counter =  isMine(int256(i)-1,int256(j)) ? counter + 1 : counter; 
                counter =  isMine(int256(i)-1,int256(j)+1) ? counter + 1 : counter; 
                counter =  isMine(int256(i),int256(j)-1) ? counter + 1 : counter; 
                counter =  isMine(int256(i),int256(j)+1) ? counter + 1 : counter; 
                counter =  isMine(int256(i)+1,int256(j)-1) ? counter + 1 : counter; 
                counter =  isMine(int256(i)+1,int256(j)) ? counter + 1 : counter; 
                counter =  isMine(int256(i)+1,int256(j)+1) ? counter + 1 : counter; 
                realBoard[i][j] = CoordinateStatus(counter);

            }
        }
    }

    function isValid(int256 x, int256 y) internal pure returns (bool) {
        if( 0 <= x && 0 <= y && uint256(x) < BOARDLENGTH && uint256(y) < BOARDLENGTH){
            return true;
        }
        return false;
    }

    function isMine(int256 x, int256 y) internal view returns (bool) {
        if( isValid(x,y) && realBoard[uint256(x)][uint256(y)] == CoordinateStatus.Mine){
            return true;
        }
        return false;
    }

    function processMove(uint256 x, uint256 y) public returns (bool) {
        if(gameStatus != GameStatus.Ongoing){
            gameStatus = GameStatus.Ongoing;
            console.log("gameStatus = GameStatus.Ongoing");
        }
        CoordinateStatus realCurrent = realBoard[x][y];
        CoordinateStatus playerCurrent = playerBoard[x][y];
        console.log("processMove 0",x,y);

        if(playerCurrent != CoordinateStatus.Untouched){
            return false;
        }

        if(realCurrent == CoordinateStatus.Mine){
            //Reveal all mines
            for(uint256 i = 0; i < numMines; i++){
                playerBoard[mines[i].x][mines[i].y] = CoordinateStatus.Mine;
            }
            emit GameEnded(false, gameId);
            gameStatus = GameStatus.Ended;
            console.log("gameStatus = GameStatus.Ended");
            return true;
        } else {
            console.log("nonMineCount",nonMineCount);
            playerBoard[x][y] = realCurrent;

            nonMineCount--;

            console.log("processMove 2",x,y);

            if(isValid(int256(x)-1,int256(y)-1) && !isMine(int256(x)-1,int256(y)-1)){
                processMove(x-1,y-1);
            }

            console.log("processMove 23",x,y);
            if(isValid(int256(x)-1,int256(y)) && !isMine(int256(x)-1,int256(y))){
                processMove(x-1,y);
            }

            console.log("processMove 24",x,y);
            if(isValid(int256(x)-1,int256(y)+1) && !isMine(int256(x)-1,int256(y)+1)){
                processMove(x-1,y+1);
            }

            console.log("processMove 25",x,y);
            if(isValid(int256(x),int256(y)-1) && !isMine(int256(x),int256(y)-1)){
                processMove(x,y-1);
            }

            console.log("processMove 26",x,y);
            if(isValid(int256(x),int256(y)+1) && !isMine(int256(x),int256(y)+1)){
                processMove(x,y+1);
            }

            console.log("processMove 27",x,y);
            if(isValid(int256(x)+1,int256(y)-1) && !isMine(int256(x)+1,int256(y)-1)){
                processMove(x+1,y-1);
            }
 
             console.log("processMove 28",x,y);
           if(isValid(int256(x)+1,int256(y)) && !isMine(int256(x)+1,int256(y))){
                processMove(x+1,y);
            }
 
             console.log("processMove 28=9",x,y);
           if(isValid(int256(x)+1,int256(y)+1) && !isMine(int256(x)+1,int256(y)+1)){
                processMove(x+1,y+1);
            }
        return false;
        }
    }

    function hasPlayerWon() public view returns (bool) {
        return nonMineCount == 0;
    }

    function getAddress() public view returns (address) {
        return address(this);
    }

    // function generateCoordinates(uint256[] memory randomWords, uint256 numCoords) internal {
    //     require(randomWords.length >= numCoords*2,"GameFactory : Too few random numbers generated");
    //     for(uint256 i = 0; i < numCoords; i++){
    //         Coordinates storage coords = mines[i];
    //         coords.x = randomWords[i];
    //         coords.y = randomWords[i+1];
    //     }
    // }

}