function [refBody, scName] = orbitPanelGetOrbitFromKSPTOTConnectActiveVesselCallBack(hSMA, hECC, hINC, hRAAN, hARG, varargin)

    refBody = [];
    [orbit] = getSingularOrbitFromKSPTOTConnect([]);
    if(not(isempty(orbit)))
        if(not(isempty(hSMA)))
            set(hSMA, 'String', fullAccNum2Str(orbit{3}));
        end
        
        if(not(isempty(hECC)))
            set(hECC, 'String', fullAccNum2Str(orbit{4}));
        end
        
        if(not(isempty(hINC)))
            set(hINC, 'String', fullAccNum2Str(orbit{5}));
        end
        
        if(not(isempty(hRAAN)))
            set(hRAAN, 'String', fullAccNum2Str(orbit{6}));
        end
        
        if(not(isempty(hARG)))
            set(hARG, 'String', fullAccNum2Str(orbit{7}));
        end
        
        refBody = orbit{10};
        scName = orbit{1};

        if(nargin == 7)
            hMA = varargin{1};
            hEpoch = varargin{2};
            set(hMA, 'String', fullAccNum2Str(rad2deg(orbit{8})));
            set(hEpoch, 'String', fullAccNum2Str(orbit{9}));
        end
    end
end