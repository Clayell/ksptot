function [truOfAN, truOfDN] = computeTruOfAscDescNodes(sma, ecc, inc, raan, arg, gmu, equatHVect)
%computeTruOfAscDescNodes Summary of this function goes here
%   Detailed explanation goes here

    hVect = computeHVect(sma, ecc, inc, raan, arg, gmu);
    nVect = cross(equatHVect, hVect)/norm(cross(equatHVect, hVect));

    truOfAN = getTAFromLineOfNodes(nVect, sma, ecc, inc, raan, arg, gmu);
    truOfDN = AngleZero2Pi(truOfAN+pi);
end
