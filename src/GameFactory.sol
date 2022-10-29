// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "./Game.sol";
import '@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol';
import '@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';


contract GameFactory is VRFConsumerBaseV2, ConfirmedOwner {
    uint256 public currentRound;
    uint256 public timeTillNextRound;
    uint256 public numberOfGamesInCurrentRound;

    /*
    CHAINLINK VARS
    */
    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);

    struct RequestStatus {
        bool fulfilled; // whether the request has been successfully fulfilled
        bool exists; // whether a requestId exists
        uint256[] randomWords;
    }
    mapping(uint256 => RequestStatus) public s_requests; /* requestId --> requestStatus */
    VRFCoordinatorV2Interface COORDINATOR;

    // Your subscription ID.
    uint64 s_subscriptionId;
    bytes32 keyHash = 0x4b09e658ed251bcafeebbc69400383d49f344ace09b9576fe248bb02c003fe9f;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 3;
    uint32 numWords = 80;

    // past requests Id.
    uint256[] public requestIds;
    uint256 public lastRequestId;

    constructor(uint256 subId) 
        VRFConsumerBaseV2(0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed)
        ConfirmedOwner(msg.sender) 
    {
        COORDINATOR = VRFCoordinatorV2Interface(0x7a1BaC17Ccc5b313516C5E16fb24f7659aA5ebed);
        s_subscriptionId = subId;
    }


    function createGame() public {
        // approval - contribute to pot
        
        // make request to chainlink

        // create new game with obtained random number tokens

        Game game = new Game(msg.sender, mines);
    }

    function generateCoordinates(uint256[] memory randomWords, uint256 numCoords) internal returns (Coordinates[] memory) {
        require(len(randomWords) >= numCoords*2,"GameFactory : Too few random numbers generated");
        Coordinates[numCoords] coords;
        for(uint256 i = 0; i < numCoords; i++){
            coords[i].x = randomWords[i];
            coords[i].y = randomWords[i+1];
        }
        return coords;
    }

    /*
    CHAINLINK FUNCS
    */
        // Assumes the subscription is funded sufficiently.
    function requestRandomWords() external onlyOwner returns (uint256 requestId) {
        // Will revert if subscription is not set and funded.
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            requestConfirmations,
            callbackGasLimit,
            numWords
        );
        s_requests[requestId] = RequestStatus({randomWords: new uint256[](0), exists: true, fulfilled: false});
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(s_requests[_requestId].exists, 'request not found');
        s_requests[_requestId].fulfilled = true;
        s_requests[_requestId].randomWords = _randomWords;
        emit RequestFulfilled(_requestId, _randomWords);
    }

    function getRequestStatus(uint256 _requestId) external view returns (bool fulfilled, uint256[] memory randomWords) {
        require(s_requests[_requestId].exists, 'request not found');
        RequestStatus memory request = s_requests[_requestId];
        return (request.fulfilled, request.randomWords);
    }

}
