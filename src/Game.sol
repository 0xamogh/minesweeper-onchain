// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";
import "./GameFactory.sol";

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

    event GameEnded(bool playerWins, uint256 roundNumber, uint256 gameId);

    Game private previousGame;
     uint256 public gameId;
     uint256 private nonMineCount;
     uint256 private numMines;
     uint256 public startTime;
     uint256 public timeTaken;
     GameStatus public gameStatus;

    CoordinateStatus[][] private playerBoard;
    CoordinateStatus[][] private realBoard;

    mapping(uint256 => Coordinates) private mines;
    // uint256[] private randomNumbers;

    constructor(uint256[] memory coordinates){
        generateCoordinates(coordinates, NUM_MINES);
        initializeGame();
    }

    function initializeGame() internal {
        nonMineCount = BOARDLENGTH*BOARDLENGTH - NUM_MINES;
        
        for(uint256 i = 0; i < BOARDLENGTH;i++){
            playerBoard[i] = new CoordinateStatus[](BOARDLENGTH); 
            realBoard[i] = new CoordinateStatus[](BOARDLENGTH); 
        }
        
        for(uint256 i = 0; i < NUM_MINES;i++){
            realBoard[mines[i].x][mines[i].y] = CoordinateStatus.Mine; 
        }
        
        intializeBoards();
        startTime = block.timestamp;
    }

    function intializeBoards() internal {
        for(uint256 i = 0; i < BOARDLENGTH; i++){
            for(uint256 j = 0; j < BOARDLENGTH; j++){
                playerBoard[i][j] = CoordinateStatus.Untouched;

                if(realBoard[i][j] == CoordinateStatus.Mine){
                    continue;
                }

                uint256 counter = 0;
                counter =  isMine(i-1,j-1) ? counter + 1 : counter; 
                counter =  isMine(i-1,j) ? counter + 1 : counter; 
                counter =  isMine(i-1,j+1) ? counter + 1 : counter; 
                counter =  isMine(i,j-1) ? counter + 1 : counter; 
                counter =  isMine(i,j+1) ? counter + 1 : counter; 
                counter =  isMine(i+1,j-1) ? counter + 1 : counter; 
                counter =  isMine(i+1,j) ? counter + 1 : counter; 
                counter =  isMine(i+1,j+1) ? counter + 1 : counter; 
                realBoard[i][j] = CoordinateStatus(counter);
            }
        }
    }

    function isValid(uint256 x, uint256 y) internal pure returns (bool) {
        if( 0 <= x && x <= BOARDLENGTH && 0 <= y && y <= BOARDLENGTH){
            return true;
        }
        return false;
    }

    function isMine(uint256 x, uint256 y) internal view returns (bool) {
        if( isValid(x,y) && realBoard[x][y] == CoordinateStatus.Mine){
            return true;
        }
        return false;
    }

    function processMove(uint256 x, uint256 y) public {
        CoordinateStatus current = realBoard[x][y];

        if(current != CoordinateStatus.Zero){
            
            playerBoard[x][y] = current;
            nonMineCount--;
            
            if(hasPlayerWon()){
                timeTaken = block.timestamp - startTime;
                emit GameEnded(true, roundNumber, gameId);
            }
            return;
        }

        if(current == CoordinateStatus.Mine){
            for(uint256 i = 0; i < numMines; i++){
                playerBoard[mines[i].x][mines[i].y] = CoordinateStatus.Mine;
            }
            emit GameEnded(false, roundNumber, gameId);
            return;
        } else {
            nonMineCount--;

            if(!isMine(x-1,y-1)){
                processMove(x-1,y-1);
            }
            if(!isMine(x-1,y)){
                processMove(x-1,y);
            }
            if(!isMine(x-1,y+1)){
                processMove(x-1,y+1);
            }
            if(!isMine(x,y-1)){
                processMove(x,y-1);
            }
            if(!isMine(x,y+1)){
                processMove(x,y+1);
            }
            if(!isMine(x+1,y-1)){
                processMove(x+1,y-1);
            }
            if(!isMine(x+1,y)){
                processMove(x+1,y);
            }
            if(!isMine(x+1,y+1)){
                processMove(x+1,y+1);
            }
        }
        return;
    }

    function hasPlayerWon() public view returns (bool) {
        return nonMineCount == 0;
    }

    function getAddress() public view returns (address) {
        return address(this);
    }

    function generateCoordinates(uint256[] memory randomWords, uint256 numCoords) internal {
        require(randomWords.length >= numCoords*2,"GameFactory : Too few random numbers generated");
        for(uint256 i = 0; i < numCoords; i++){
            Coordinates storage coords = mines[i];
            coords.x = randomWords[i];
            coords.y = randomWords[i+1];
        }
    }

}