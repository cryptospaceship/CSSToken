pragma solidity ^0.4.25;

import "./Mortal.sol";
import "./AddressUtils.sol";

contract CSSGenAttribInterface {
    function genUpgradeLevel(uint _level, uint _points, uint get, uint pointsEarned) 
        external 
        pure 
        returns (
            uint level, 
            uint progress, 
            uint qaimPoints, 
            uint points
        );
    function getGenQAIM(uint gen) external pure returns (uint qaim);
    function getGenBasePoints(uint gen) external pure returns (uint bp);
}

contract CSSGenAttrib is Mortal {
        
    using AddressUtils for address;
    CSSGenAttribInterface Interface;

    function setCSSGenAttribInterface(address _contract)
        external
        onlyOwner
    {
        require(_contract.isContract());
        Interface = CSSGenAttribInterface(_contract);
    }

    function genUpgradeLevel(uint _level, uint _points, uint gen, uint pointsEarned)
        internal
        view
        returns (
            uint level, 
            uint progress, 
            uint qaimPoints, 
            uint points
        )
    {
        if (Interface == address(0)) {
            level = _level;
            progress = 0;
            qaimPoints = 0;
            points = _points + pointsEarned;
        } else {
            (level,progress,qaimPoints,points) = Interface.genUpgradeLevel(_level,_points,gen,pointsEarned);
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

    function getGenBasePoints(uint gen)
        internal
        view
        returns(uint)
    {
        if (Interface == address(0))
            return 5;
        else 
            return Interface.getGenBasePoints(gen);
    }
}
