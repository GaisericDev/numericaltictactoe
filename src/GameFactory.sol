// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// @title Creates and handles numerical tic tac toe games
// @author Sebastiaan Crisan (GaisericDev)
// @notice Work in progress towards MVP, probably has crappy algos and gas optimization for now i.e. memory arrays and uint8 in memory
/*
   @dev
    TODO:
    - Add ownable + permissions
    - Refactor to uint256 wherever possible (used uint8 for the tighter struct)
    - Prevent players from using a number more than once
    - Prevent players from joining (overwriting) games with 2 players
    - Check who won the game
    - Add draw clause
    - Prevent game from continuing after game has ended
    - Customizeable odd / even for p1 / p2
    - Add diagonal win con
    - Add tokens as reward upon win
    - Make vs ai mode
    - Make fog of war mode using zk proof
    - Test when a contract deployment for a new game would be more desireable than creating a struct  
    - ...
*/
contract GameFactory {
    // Game struct that will contain the state of a given game.
    struct Game {
        uint8[][] board;
        uint8 dimensions;
        bool turn; //for now, let's assume p1 always starts (turn = false) and is always odd
        bool gameStarted;
        bool gameEnded;
        bool p1Won;
        bool p2Won;
        bool draw;
        address p1;
        address p2;
    }
    // List of created games
    // Game[] public games;
    // Mapping of game id's to games
    uint gameCount = 0;
    mapping (uint => Game) public games;
    // Ensure player is not the a contract
    modifier isEOA {
        require(tx.origin == msg.sender, "Not a valid player");
        _;
    }
    // Ensure only players of the game can interact with the game
    modifier isPlayer(uint256 _id){
        Game memory game = games[_id];
        require(msg.sender == game.p1 || msg.sender == game.p2, "Only players can do this!");
        _;
    }
    // Ensure a move is legal;
    modifier isLegalMove(uint256 _id, uint8 _x, uint8 _y, uint8 _value) {
        Game memory game = games[_id];
        require(_value < 10 && _value != 0, "Must be a valid number!");
        require(game.board[_y][_x] == 0, "Square is not empty!");
        // turn = true: needs an even number (p2 turn), turn = false: needs an odd number (p1 turn)
        require(game.turn ? _value % 2 == 0 : _value % 2 == 1, "That number does not belong to you!");
        require(game.turn ? msg.sender == game.p2 : msg.sender == game.p1, "It is not your turn!");
        _;
    }
    // New game event
    // event NewGame(address _gameAddress);
    event NewGame(Game _newGame);
    // Player has joined event
    event Joined(address _player);

    // Create PvP game
    // @dev Creates a temp array + struct in memory that is then put into storage, might be a more efficient way to do this
    function createPvP(uint8 _boardSize) public payable isEOA{
        require(_boardSize > 2, "Invalid board size"); // Boards of 0x0 and 1x1 and 2x2 are useless
        gameCount++;
        Game memory newGame;
        newGame.gameStarted = true;
        newGame.p1 = msg.sender;
        newGame.dimensions = _boardSize;
        uint8[][] memory temp = new uint8[][](_boardSize);
        for(uint8 i = 0; i < _boardSize; i++){
            temp[i] = new uint8[](_boardSize);
            for(uint8 j = 0; j < _boardSize; j++){
                temp[i][j] = 0;
            }
        }
        newGame.board = temp;
        games[gameCount -1] = newGame;
        // Emit new game event
        emit NewGame(games[gameCount - 1]);
    }

    // Join game for p2
    function join(uint256 _id) public payable isEOA{
        require(games[_id].gameStarted == true, "This is not a valid game!");
        require(msg.sender != games[_id].p1, "Can't join your own game!");
        require(games[_id].p2 == address(0), "Game full!");
        // Set p2 
        games[_id].p2 = msg.sender;
        // Emit event p2 has joined
        emit Joined(msg.sender);
    }

    // Make a move 
    function makeMove(uint256 _id, uint8 _x, uint8 _y, uint8 _value) public payable isPlayer(_id) isLegalMove(_id, _x, _y, _value) {
        // Make the move
        games[_id].board[_y][_x] = _value;
        // Check if winner
        bool hasWon = checkWin(_id);
        if(hasWon){
            games[_id].p1Won = true;
            games[_id].gameEnded = true;
        }
        // Toggle turn
        games[_id].turn = !games[_id].turn;
    }

    // Check win
    function checkWin(uint256 _id) internal view returns (bool){
        uint8 n = games[_id].dimensions;
        // Window slider of size k on row r
        for(uint8 r = 0; r < n; r++){
            for(uint k = 2; k <= n; k++){ // O(n^2)
                bool wonHorizontal = windowSlide(games[_id].board, n, k, r); // O(n)
                bool wonVertical = windowSlide(rotate(games[_id].board, n), n, k, r); // O(n^2) => O((n + n^2)^2)
                if(wonHorizontal || wonVertical){
                    return true;
                }
            }
        }
        return false;
    }

    // Rotate the board 90 degrees so we can treat a column as a row for the window slider algo
    // https://stackoverflow.com/questions/42519/how-do-you-rotate-a-two-dimensional-array
    function rotate(uint8[][] memory _board, uint8 n) internal pure returns (uint8[][] memory){
        uint8 layerCount = n / 2;
        for(uint8 i = 0; i < layerCount; i++){
            uint8 first = i;
            uint8 last = n - first - 1;
            
            for(uint8 j = first; j < last; j++){
                uint8 offset = j - first;
                uint8 top = _board[first][j];
                uint8 rightSide = _board[j][last];
                uint8 bottom = _board[last][last - offset];
                uint8 leftSide = _board[last - offset][first];

                _board[first][j] = leftSide;
                _board[j][last] = top;
                _board[last][last - offset] = rightSide;
                _board[last - offset][first] = bottom;
            }
        }
        return _board;
    }

    // Window slider through the row
    // @param _board The game board
    // @param n The board dimensions
    // @param k The window slider size
    // @param r The current row
    function windowSlide(uint8[][] memory _board, uint8 n, uint k, uint8 r) internal pure returns (bool) {
        uint8 sum = 0;
        // Window slider all the way to the left
        for(uint i = 0; i < k; i++){
            sum += _board[r][i];
        }
        // Check if we have 15
        if(sum == 15){
            return true;
        }
        // Iterate array once and increment on right edge
        for(uint i = k; i < n; i++){
            sum += _board[r][i]; // add next el
            sum -= _board[r][i - k]; // remove previous el
            // if previous el > sum + next el, then we could reach a negative number, however, since the previous el is already included in sum, this should never happen
            if(sum == 15){
                return true;
            }
        }
        return false;
    }

    // Getter for a game
    function getGame(uint id)public view returns (Game memory){
        return games[id];
    }

    // Fallback in case ETH ends up here
    fallback() external{}
}