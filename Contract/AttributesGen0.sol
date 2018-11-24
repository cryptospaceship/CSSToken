pragma solidity 0.4.25;


contract AttributesGen0 {
    function genUpgradeLevel(uint _level, uint _points, uint gen, uint pointsEarned) 
        external 
        pure 
        returns (
            uint level, 
            uint progress, 
            uint qaimPoints, 
            uint points
        )
    {
        if (gen == 0) {
            points = _points + pointsEarned;
            level = points / 1000;
            if (level > _level) {
                // Gano Puntos
                qaimPoints = (level - _level) * 5;
            }
            progress = ((points % 1000) * 100) / 1000;
        }
    }

    function getGenQAIM(uint gen) 
        external 
        pure 
        returns (uint qaim)
    {
        if (gen == 0)
            qaim = 6;
    }

    function getGenBasePoints(uint gen) 
        external 
        pure 
        returns (uint bp)
    {
        if (gen == 0)
            bp = 5;
    }
}
