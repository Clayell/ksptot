function [spinAngle] = getBodySpinAngle_alg(rotperiod, rotini, ut)
%getBodySpinAngle Summary of this function goes here
%   Detailed explanation goes here

    bodySpinRate = 2*pi/rotperiod; %rad/sec
    rotInit = deg2rad(rotini);     %rad, at t=0;
    spinAngle = AngleZero2Pi(rotInit + bodySpinRate.*ut); %theta, rad
end

