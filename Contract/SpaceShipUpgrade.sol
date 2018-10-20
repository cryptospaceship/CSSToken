pragma solidity ^0.4.25;

import "./Mortal.sol";
import "./AddressUtils.sol";

contract SpaceShipUpradeInterface {
    function calcLevel(uint level, uint points, uint get, uint pointsEarned) 
        external 
        pure 
        returns (
            uint level, 
            uint progress, 
            uint qaimPoints, 
            uint points
        );

    function getGenQAIM(uint gen) external pure returns (uint qaim);
}

contract SpaceShipUpgrade is Mortal {
        
    using AddressUtils for address;
    address Interface;

    constructor() public {
        Interface = address(0);
    }

    function setUpgradeInterface(address _contract)
        external
        onlyOwner
    {
        require(_contract.isContract());
        Interface = SpaceShipUpgradeInterface(_contract);
    }

    function calcLevel(uint level, uint points, uint gen, uint pointsEarned)
        internal
        view
        returns (
            uint level, 
            uint progress, 
            uint qaimPoints, 
            uint points
        );
    {
        if (Interface == address(0)) {
            level = level;
            progress = 0;
            qaimPoints = 0;
            points = points + pointsEarned;
        } else {
            (level,progress,qaimPoints,points) = Interface.calcLevel(level,points,gen,pointsEarned);
        }
    }

    function getGenQAIM(uint gen)
        internal
        view
        returns (uint)
    {
        if (Interface == address(0)) 
            return 6;
        else
            return Interface.getGenQAIM(gen);
    }
}
