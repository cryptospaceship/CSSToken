pragma solidity ^0.4.23;

import "./SpaceShipGame.sol";
import "./SafeMath.sol";

contract SpaceShipGameplay is SpaceShipGame {

    using SafeMath for uint;

    modifier canPlaceInGame(uint _ship) {
        require (
            isPlaying(_ship) == false,
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
    {
        uint _game = gameAddr[msg.sender];
        ships[_ship].gameId = _game;
        ships[_ship].plays = ships[_ship].plays.add(1);
    }	
    
    function isPlaying(uint _ship)
        internal
        view
        returns(bool)
    {
        return gameValid[ships[_ship].gameId];
    }

    /**
     * Falta colectar los puntos
     */
    function exitGame(uint _ship) 
        external 
        onlyShipOwner(_ship) 
    {
        Ship storage ship = ships[_ship];
        uint _game = ship.gameId;
        uint points;
        bool win;

        require(gameValid[_game]);
        
        (win, points) = game[_game].gameInterface.removeShip(_ship);

        if (win) 
            ship.wins++;

        (ship.level,,ship.unassignedPoints,ship.points) = genUpgradeLevel(ship.level,ship.points,ship.gen,points);

        ship.gameId = invalidGame();
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

    function getCurrentGen()
        external
        view
        returns(uint)
    {
        return currentGen;
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
            address owner,
            string name,
            uint color,
            uint gen,
            uint points,
            uint level,
            uint plays,
            uint wins,
            uint launch,
            uint progress,
            uint qaims,
            bool inGame
        ) 
    {
        owner = shipToOwner[_ship];
        name = ships[_ship].name;
        color = ships[_ship].color;
        gen = ships[_ship].gen;
        points = ships[_ship].points;
        level = ships[_ship].level;
        plays = ships[_ship].plays;
        wins = ships[_ship].wins;
        launch = ships[_ship].launch;
        (,progress,,) = genUpgradeLevel(level,points,gen,0);
        qaims = getGenQAIM(gen);
        inGame = isPlaying(_ship);
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
    
}
