classdef LaunchVehiclePowerSinkEnum < matlab.mixin.SetGet
    %LaunchVehiclePowerSinkEnum Summary of this class goes here
    %   Detailed explanation goes here
    
    enumeration
        Simple('Simple Power Sink');
    end
    
    properties
        name(1,:) char
    end
    
    methods
        function obj = LaunchVehiclePowerSinkEnum(name)
            obj.name = name;
        end
    end
    
    methods(Static)
        function listBoxStr = getListBoxStr()
            m = enumeration('LaunchVehiclePowerSinkEnum');
            [~,I] = sort({m.name});
            listBoxStr = {m(I).name};
        end
        
        function [ind, enum] = getIndForName(name)
            m = enumeration('LaunchVehiclePowerSinkEnum');
            [~,I] = sort({m.name});
            m = m(I);
            ind = find(ismember({m.name},name),1,'first');
            enum = m(ind);
        end
        
        function [enum, ind] = getEnumForListboxStr(nameStr)
            m = enumeration('LaunchVehiclePowerSinkEnum');
            ind = find(ismember({m.name},nameStr),1,'first');
            enum = m(ind);
        end
    end
end