classdef LaunchVehicleExtrema < matlab.mixin.SetGet
    %LaunchVehicleExtrema Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        lvdData LvdData
        
        quantStr char 
        type(1,1) LaunchVehicleExtremaTypeEnum = LaunchVehicleExtremaTypeEnum.Maximum;
        startingState(1,1) LaunchVehicleExtremaRecordingEnum = LaunchVehicleExtremaRecordingEnum.Recording;
        frame AbstractReferenceFrame
        unitStr char
        
        id(1,1) double = 0;
        
        %deprecated
        refBody KSPTOT_BodyInfo
    end
    
    methods
        function obj = LaunchVehicleExtrema(lvdData)
            obj.lvdData = lvdData;
            
            obj.id = rand();
        end
        
        function nameStr = getNameStr(obj)
            nameStr = sprintf('%s %s [%s]', obj.type.nameStr, obj.quantStr, obj.frame.getNameStr());
        end
        
        function initState = createInitialState(obj)
            initState = LaunchVehicleExtremaState(obj);
            
            initState.active = obj.startingState;
        end
        
        function tf = isInUse(obj)
            tf = obj.lvdData.usesExtremum(obj);
        end
    end
    
    methods(Static)
        function obj = loadobj(obj)
            if(isempty(obj.frame))
                if(not(isempty(obj.refBody)))
                    obj.frame = obj.refBody.getBodyCenteredInertialFrame();
                else
                    obj.frame = LvdData.getDefaultInitialBodyInfo(obj.lvdData.celBodyData).getBodyCenteredInertialFrame();
                end
            end
        end
    end
end