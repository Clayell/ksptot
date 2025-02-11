function [refBody, scName] = orbitPanelGetOrbitFromSFSContextCallBack(hSMA, hECC, hINC, hRAAN, hARG, varargin)
%orbitPanelGetOrbitFromSFSContextCallBack Summary of this function goes here
    global GLOBAL_prevPathName %#ok<GVMIS>

%   Detailed explanation goes here
    % if(not(isempty(mainGUIHandle)))
    %     mainUserData = get(mainGUIHandle,'UserData');
    %     prevPathName = mainUserData{3,1};
    % else
    %     mainUserData = [];
    %     prevPathName = [];
    % end

    prevPathName = GLOBAL_prevPathName;
    
    refBody = [];
%     [orbit,PathName,scName] = importOrbitGUI(1, prevPathName);

    output = AppDesignerGUIOutput({[],[],''});
    importOrbitGUI_App(1, prevPathName, output);
    orbit = output.output{1};
    PathName = output.output{2};
    scName = output.output{3};

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
        
        if(nargin == 7)
            hMA = varargin{1};
            hEpoch = varargin{2};
            set(hMA, 'String', fullAccNum2Str(orbit{8}));
            set(hEpoch, 'String', fullAccNum2Str(orbit{9}));
        end
        
        % if(not(isempty(mainUserData)))
        %     mainUserData{3,1} = PathName;
        %     set(mainGUIHandle,'UserData',mainUserData);
        % end
        GLOBAL_prevPathName = PathName;
    end
end

