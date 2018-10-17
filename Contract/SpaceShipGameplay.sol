pragma solidity ^0.4.23;

import "./SpaceShipGame.sol";
import "./SafeMath.sol";

contract SpaceShipGameplay is SpaceShipGame {

    using SafeMath for uint;

    modifier canPlaceInGame(uint _ship) {
        require (
            gameValid[ships[_ship].gameId] == false,
            "The ship can not place in Game"
        );
        _;
    }

    modifier onlyValidGame() {
        require (
            gameValid[gameAddr[msg.sender]],
            "Invalid game is a sender"
        );
        _;
    }

    /**
     * @dev Set and Start playing in a Game.
     * Throw if:
     *         - Caller not the ship owner
     *         - Can not place in a game: Ship is playing in other game
     *         - msg.value != to the game ticket
     *         - fail interface calling
     * @param _ship Ship Id
     */
    function setGame(uint _ship) 
        external 
        onlyValidGame
        canPlaceInGame(_ship)
        returns(bool) 
    {
        uint _game = gameAddr[msg.sender];
        require(_setGame(_ship,_game));
        return true;
    }	
    
    /**
     *
     */
    function unsetGame(uint _ship) 
        external 
        onlyShipOwner(_ship) 
        returns(bool) 
    {
        uint _game = ships[_ship].gameId;
        require(gameValid[_game]);
        require(game[_game].gameInterface.unplaceShip(_ship) == true);
        require(_unsetGame(_ship,_game));
        return true;
    }

    function throwShip(uint _ship)
        external
        onlyGame(_ship)
        returns (bool)
    {
        uint _game = ships[_ship].gameId;
        require(_unsetGame(_ship,_game));
        return true;
    }

    function setQAIM(uint _ship, uint[32] qaim)
        external
        onlyShipOwner(_ship)
    {
        uint i;
        uint points = 0;
        Ship storage s = ships[_ship];
        
        for (i = 0; i <= 32-1; i++) {
            points = points + qaim[i];
            s.qaim[i] = s.qaim[i] + uint8(qaim[i]);
        }
        require(
            canAssign(_ship,points), 
            "Assigned points are grather than available points"
        );
        s.unassignedPoints = s.unassignedPoints - points;
    }

    function getUnassignedPoints(uint _ship)
        external
        view
        returns(uint)
    {
        return ships[_ship].unassignedPoints;
    }

    function canAssign(uint _shipId, uint _points)
        internal
        view
        returns(bool)
    {
        return ships[_shipId].unassignedPoints >= _points;
    }

    function getShipGame(uint _ship)
        external
        view
        returns(uint game)
    {
        if (gameValid[ships[_ship].gameId])
            game = ships[_ship].gameId;
        else
            game = invalidGame();
    }
        

    function getShip(uint _ship) 
        external 
        view 
        returns 
        (
            string name,
            uint color,
            bool inGame,
            address owner,
            uint level,
            uint takedowns,
            uint wins,
            uint losses,
            uint launch
        ) 
    {
        name = ships[_ship].name;
        color = ships[_ship].color;
        inGame = gameValid[ships[_ship].gameId];
        owner = shipToOwner[_ship];
        level = ships[_ship].level;
        takedowns = ships[_ship].takedowns;
        wins = ships[_ship].wins;
        losses = ships[_ship].losses;
        launch = ships[_ship].launch;
    }

    function getShipsByOwner(address _owner) 
        external 
        view 
        returns(uint[]) 
    {
        uint[] memory result = new uint[](ownerShipCount[_owner]);
        uint   counter = 0;
        for (uint i = shipBaseId; i < totalShips + shipBaseId; i++) {
            if (shipToOwner[i] == _owner) {
                result[counter] = i;
                counter++;
            }
        }
        return result;
    } 

    function getShipQAIM(uint _ship) 
        external 
        view 
        returns 
        (
            uint8[32] qaim
        ) 
    {
        qaim = ships[_ship].qaim;
    }

    function getQAIM(uint _ship, uint qaim)
        external
        view
        returns(uint)
    {
        return uint(ships[_ship].qaim[qaim]);
    }

    function _setGame(uint _ship, uint _game) 
        internal 
        returns(bool)
    {
        ships[_ship].gameId = _game;
        game[_game].players = game[_game].players.add(1);
        return true;
    }
    
    function _unsetGame(uint _ship, uint _game)
        internal 
        returns(bool) 
    {
        ships[_ship].gameId = invalidGame();
        game[_game].players = game[_game].players.sub(1);
        return true;
    }
}
