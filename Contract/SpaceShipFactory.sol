pragma solidity ^0.4.23;

import "./SafeMath.sol";
import "./Ownable.sol";

contract SpaceShipFactory is Ownable {

        
    struct Ship {
        string name;
        uint color;
        uint gameId;
        uint level;
        uint takedowns;
        uint wins;
        uint losses;
        uint8[32] qaim;
        uint unassignedPoints;
        uint gen;
        uint launch;
    }

    mapping (uint => Ship) ships;
    mapping (uint => address) public shipToOwner;
    mapping (address => uint) ownerShipCount;
    mapping (uint => bool) public shipExist;
    mapping (bytes32 => bool) shipNameHash;
    
    uint public totalShips;
    uint public maxShipSupply;
    uint public shipBaseId;
    uint nextId;

    /*
     * SpaceShip price
     */
    uint public shipPrice;

    using SafeMath for uint;
    
    event ShipCreation
    (
        uint shipId,
        string name,
        address owner,
        uint launching
    );


    modifier onlyShipOwner(uint _shipId) {
        require(msg.sender == shipToOwner[_shipId]);
        _;
    }

    constructor() 
        public 
    {
        totalShips = 0;
        maxShipSupply = 1000000;
        shipPrice = 0.01 ether;
        shipBaseId = 1000;
        nextId = shipBaseId;
    }

    function createShip(string name, uint color) 
        external 
        payable
    {
        require(totalShips + 1 < maxShipSupply);
        require(msg.value == shipPrice);
        _createShip(name, color);	
    }

    /**
     * @dev Only contract owner can change the ship price
     * @param _price the new ship price
     */
    function setCreationShipPrice(uint _price) 
        external
        onlyOwner
    {
        shipPrice = _price;
    }

    /**
     * @dev Only contract owner can change maxShipSupply
     */
    function setMaxShipSupply(uint _newMax)
        external
        onlyOwner
    {
        maxShipSupply = _newMax;
    }

    /**
     * @dev get actual ship creation price
     * @return price
     */
    function getCreationShipPrice() 
        external
        view
        returns(uint)
    {
        return shipPrice;	
    }

    /**
     * @dev check if name is elegible
     * @param name nombre
     * @return true or false
     */
    function checkName(string name)
        external
        view
        returns(bool)
    {
        bytes32 nameHash = keccak256(name);
        return !shipNameHash[nameHash];
    }

    function getBalance() 
        external
        view
        returns(uint)
    {
        return address(this).balance; 				
    }

    function withdrawAll()
        external
        onlyOwner
    {
        owner.transfer(address(this).balance);
    }	 

    function withdraw(uint _amount)
        external
        onlyOwner
    {
        require(_amount <= address(this).balance);
        owner.transfer(_amount);
    }	

    function _createShip(string name, uint color)
        internal
        returns(uint)
    {
        uint _id = nextId;
        bytes32 nameHash = keccak256(name);

        require(
            shipNameHash[nameHash] == false;
        );
        nextId = nextId.add(1);

        shipNameHash[nameHash] = true;
        shipExist[_id] = true;
        shipToOwner[_id] = msg.sender;

        ships[_id].name = name;
        ships[_id].color = color;
        ships[_id].launch = block.number;
        ships[_id].unassignedPoints = 5;
        
        totalShips = totalShips.add(1);

        ownerShipCount[msg.sender] = ownerShipCount[msg.sender].add(1);
        emit ShipCreation(_id, name, msg.sender, block.number);
    }
}
