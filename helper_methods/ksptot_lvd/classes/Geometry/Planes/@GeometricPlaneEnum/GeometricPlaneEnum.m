classdef GeometricPlaneEnum < matlab.mixin.SetGet
    %GeometricPlaneEnum Summary of this class goes here
    %   Detailed explanation goes here
    
    enumeration
        PointVectorPlane('Normal Vector at Point');
        ThreePointPlane('Three Point Plane');
    end
    
    properties
        name(1,:) char
    end
    
    methods
        function obj = GeometricPlaneEnum(name)
            obj.name = name;
        end
    end
    
    methods(Static)
        function listBoxStr = getListBoxStr()
            m = enumeration('GeometricPlaneEnum');
            [~,I] = sort({m.name});
            listBoxStr = {m(I).name};
        end
        
        function [ind, enum] = getIndForName(name)
            m = enumeration('GeometricPlaneEnum');
            [~,I] = sort({m.name});
            m = m(I);
            ind = find(ismember({m.name},name),1,'first');
            enum = m(ind);
        end
        
        function [enum, ind] = getEnumForListboxStr(nameStr)
            m = enumeration('GeometricPlaneEnum');
            ind = find(ismember({m.name},nameStr),1,'first');
            enum = m(ind);
        end
    end
end