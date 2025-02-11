function pressure = getPressureAtAltitude(bodyInfo, altitude)
    if(altitude > bodyInfo.atmohgt || (bodyInfo.doNotUseAtmoPressCurveGI))
        pressure = 0;
    else
        if(altitude < 0)
            pressure = bodyInfo.atmopresscurve(0);
        else
            pressure = bodyInfo.atmopresscurve(altitude);
        end
    end
end