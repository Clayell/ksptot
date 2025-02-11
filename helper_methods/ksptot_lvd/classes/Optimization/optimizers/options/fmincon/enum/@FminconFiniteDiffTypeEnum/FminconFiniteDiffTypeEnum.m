classdef FminconFiniteDiffTypeEnum < matlab.mixin.SetGet
    %FminconFiniteDiffTypeEnum Summary of this class goes here
    %   Detailed explanation goes here
    
    enumeration
        TwoPtForwardDiff('forward', 'Forward Difference')
        ThreePtCentralDiff('central', 'Central Difference');
    end
    
    properties
        optionStr char = ''
        name char = '';
    end
    
    methods
        function obj = FminconFiniteDiffTypeEnum(optionStr, name)
            obj.optionStr = optionStr;
            obj.name = name;
        end
    end
    
    methods(Static)
        function listBoxStr = getListBoxStr()
            m = enumeration('FminconFiniteDiffTypeEnum');
            [~,I] = sort({m.name});
            listBoxStr = {m(I).name};
        end
        
        function [ind, enum] = getIndForName(name)
            m = enumeration('FminconFiniteDiffTypeEnum');
            [~,I] = sort({m.name});
            m = m(I);
            ind = find(ismember({m.name},name),1,'first');
            enum = m(ind);
        end
        
        function [enum, ind] = getEnumForListboxStr(nameStr)
            m = enumeration('FminconFiniteDiffTypeEnum');
            ind = find(ismember({m.name},nameStr),1,'first');
            enum = m(ind);
        end
    end
end