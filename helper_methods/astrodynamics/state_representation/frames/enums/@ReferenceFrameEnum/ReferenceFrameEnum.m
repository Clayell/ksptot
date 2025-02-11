classdef ReferenceFrameEnum < matlab.mixin.SetGet
    %ReferenceFrameEnum Summary of this class goes here
    %   Detailed explanation goes here
    
    enumeration
        BodyCenteredInertial('Body-Centered Inertial');
        BodyFixedRotating('Body-Fixed Rotating');
        TwoBodyRotating('Two Body Rotating');
        UserDefined('User-Defined Geometric');
    end
    
    properties
        name(1,:) char
    end
    
    methods
        function obj = ReferenceFrameEnum(name)
            obj.name = name;
        end
    end
    
    methods(Static)
        function [listBoxStr, m] = getListBoxStr()
            m = enumeration('ReferenceFrameEnum');
            [~,I] = sort({m.name});
            listBoxStr = {m(I).name};
            m = m(I);
        end
        
        function [ind, enum] = getIndForName(name)
            m = enumeration('ReferenceFrameEnum');
            [~,I] = sort({m.name});
            m = m(I);
            ind = find(ismember({m.name},name),1,'first');
            enum = m(ind);
        end
        
        function [enum, ind] = getEnumForListboxStr(nameStr)
            m = enumeration('ReferenceFrameEnum');
            ind = find(ismember({m.name},nameStr),1,'first');
            enum = m(ind);
        end
    end
end