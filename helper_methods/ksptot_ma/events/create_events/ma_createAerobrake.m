function aerobrake = ma_createAerobrake(name, dragCoeff, dragModel, lineColor, lineStyle, lineWidth)
%ma_createAerobrake Summary of this function goes here
%   Detailed explanation goes here

    aerobrake = struct();
    aerobrake.name	    = name;
    aerobrake.type      = 'Aerobrake';
    aerobrake.dragCoeff = dragCoeff;
    aerobrake.dragModel = dragModel;
    aerobrake.lineColor = lineColor;
    aerobrake.lineStyle = lineStyle;
    aerobrake.lineWidth = lineWidth;
    aerobrake.id        = rand(1);
end

