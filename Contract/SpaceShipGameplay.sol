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

    /**
     * @dev Increment the number of takedowns after a battle. Only the game
     * can call this function
     * @param _ship the ship ID
     * @param _takedowns the number of takedows
     * @return bool    
     */
    function gameIncTakedownsToShip(uint _ship, uint _takedowns)
        external 
        onlyGame(_ship) 
        returns(bool) 
    {
        ships[_ship].takedowns = ships[_ship].takedowns.add(_takedowns);
        return true;
    }
    
    /**
     * @dev Increment in 1 the number of wins. Only the game can call this function
     * @param _ship Ship ID
     */
    function gameIncWinsToShip(uint _ship) 
        external 
        onlyGame(_ship) 
        returns(bool) 
    {
        ships[_ship].wins = ships[_ship].wins.add(1);
        return true;
    }
    
    /**
     * @dev Increment in 1 the number of Losses. Only the game can call this function
     * @param _ship Ship ID
     */
    function gameIncLossesToShip(uint _ship) 
        external 
        onlyGame(_ship) 
        returns(bool) 
    {
        ships[_ship].losses = ships[_ship].losses.add(1);
        return true;
    }

    function gameSetBattleLose(uint _ship, uint takedowns)
        external
        onlyGame(_ship)
        returns(bool)
    {
        ships[_ship].losses += 1;
        ships[_ship].takedowns += takedowns;
        return true;
    }

    function gameSetBattleWin(uint _ship, uint takedowns)
        external
        onlyGame(_ship)
        returns(bool)
    {
        ships[_ship].wins += 1;
        ships[_ship].takedowns += takedowns;
        return true;
    }

    function changeShipName(uint _ship, string _name)
        external
        onlyShipOwner(_ship)
    {
        ships[_ship].name = _name;
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


    function getShipQaim(uint _ship) 
        external 
        view 
        returns 
        (
            uint8[32] qaim
        ) 
    {
        qaim = ships[_ship].qaim;
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
