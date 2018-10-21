pragma solidity ^0.4.23;

contract SpaceShipInterface {

    function throwShip(uint _ship) external returns(bool);

    function getQAIM(uint _ship, uint qaim) external view returns(uint);

    function getShip(uint _ship) external view
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
        );

    function getShipQaim(uint _ship) external view
        returns
        (
            uint8[32] qaim
        );
        
    function setGame(uint _ship) external returns(bool);

}


