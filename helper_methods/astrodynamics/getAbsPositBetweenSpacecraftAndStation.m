function [rVect] = getAbsPositBetweenSpacecraftAndStation(time, rVectSC, bodySC, station, celBodyData)
%getAbsPositBetweenSpacecraftAndStation Summary of this function goes here
%   Detailed explanation goes here

    stnBodyInfo = getBodyInfoByNumber(station.parentID, celBodyData);
    dVect = getAbsPositBetweenSpacecraftAndBody(time, rVectSC, bodySC, stnBodyInfo, celBodyData);
    stnRVectECIRelToParent = getInertialVectFromLatLongAlt(time, station.lat, station.long, station.alt, stnBodyInfo, [NaN;NaN;NaN]);
    rVect = dVect + stnRVectECIRelToParent;
end

