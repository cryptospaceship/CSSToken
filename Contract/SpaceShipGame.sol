pragma solidity ^0.4.23;

import "./SpaceShipFactory.sol";
import "./AddressUtils.sol";
import "./SafeMath.sol";


contract GameInterface {
    function removeShip(uint _ship) external returns(bool win, uint points);
}

contract SpaceShipGame is SpaceShipFactory {

    struct Game {
        GameInterface gameInterface;
        address	addr;
    }

    mapping (uint => Game) game;
    mapping (uint => bool) gameValid;
    mapping (address => uint) gameAddr;
    uint gameCount;
    uint gameIds;

    using AddressUtils for address;
    using SafeMath for uint;

    modifier onlyGame(uint _shipId) {
        require(isSettedGame(msg.sender,_shipId));
        _;
    }

    constructor()
        public
    {
        gameCount = 0;
        gameIds = 1;
    }

    /**
     * @dev Add a playable game
     * @param _contract Contract address of the Game
     * @return _id Id of the new Game
     */
    function addgame(address _contract)
        external
        onlyOwner
        returns(uint)
    {
        require(_contract.isContract());
        uint _id = gameIds;
        gameCount = gameCount.add(1);
        gameIds = gameIds.add(1);
        gameAddr[_contract] = _id;
        game[_id].addr = _contract;
        gameValid[_id] = true;
        return _id;
    }


    /**
     * @dev Destroy a finished game
     * @param _id Game id
     * @return _id Game id
     */
    function delGame(uint _id)
        external
        onlyOwner
        returns(uint)
    {
        require(gameValid[_id] == true);
        /*
            TODO: Check game[_id].players > 0 and
            clean all ships
         */
        gameValid[_id] = false;
        delete game[_id];
        gameCount = gameCount.sub(1);
        return _id;
    }

    /**
     * @dev Return all actives games ids
     * @return ids array of active ids
     */
    function getAllGames()
        external
        view
        returns(uint[] ids)
    {
        uint i;
        uint j = 0;
        ids = new uint[](gameCount);
        for ( i = 1; i < gameIds; i++ ) {
            if (gameValid[i]) {
                ids[j] = i;
                j = j + 1;
            }
        }
    }

    /**
     * @dev Return detailed info of a specific Game
     * @param _id Game ID
     * @return name Game Name of Solar System Name
     * @return id Currend if Game
     * @return players Number of players in the game
     * @return blocksAge Age of the game measured in blocks
     * @return value Price in wei to play
     */
    function getGame(uint _id) external view
        returns (uint id, address addr)
    {
        addr = game[_id].addr;
        id = _id;
    }

    /**
     * @dev Check if the _caller is where the ship is Setted
     * @param _caller Contract address
     * @param _shipId Id of the ship
     * @return bool
     */
    function isSettedGame(address _caller, uint _shipId)
        internal
        view
        returns(bool)
    {
        uint gameId = ships[_shipId].gameId;
        if (gameValid[gameId] == true && _caller == game[gameId].addr)
            return true;
        return false;
    }

    /**
     * @dev return invalid Game ID
     */
    function invalidGame() internal pure returns(uint)
    {
        return 0;
    }
}