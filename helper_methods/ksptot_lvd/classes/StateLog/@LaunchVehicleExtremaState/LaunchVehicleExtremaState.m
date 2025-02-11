classdef LaunchVehicleExtremaState < matlab.mixin.SetGet & matlab.mixin.Copyable
    %LaunchVehicleExtremaState Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        extrema LaunchVehicleExtrema
        value(1,1) double = NaN;
        active(1,1) LaunchVehicleExtremaRecordingEnum = LaunchVehicleExtremaRecordingEnum.Recording;
    end
    
    properties(Constant)
        gaTaskList = ma_getGraphAnalysisTaskList(getLvdGAExcludeList());
    end
    
    methods
        function obj = LaunchVehicleExtremaState(extrema)
            obj.extrema = extrema;
        end
        
        function val = getValue(obj)
            val = obj.value;
        end
                
        function [newValue] = updateExtremaStateWithStateLogEntry(obj, stateLogEntry, prevValue)    
            if(obj.active == LaunchVehicleExtremaRecordingEnum.Recording) %if it's not recording, then we can just return the exState as it is b/c it won't change     
                maTaskList = LaunchVehicleExtremaState.gaTaskList;
                
                maSubLog = stateLogEntry.getMAFormattedStateLogMatrix(true);
                taskStr = obj.extrema.quantStr;
                prevDistTraveled = 0;
                refBodyId = obj.extrema.frame.getOriginBody().id;
                propNames = obj.extrema.lvdData.launchVehicle.tankTypes.getFirstThreeTypesCellArr();

                celBodyData = obj.extrema.lvdData.celBodyData;

                if(ismember(taskStr,maTaskList))
                    [depVarValue, depVarUnit, ~] = ma_getDepVarValueUnit(1, maSubLog, taskStr, prevDistTraveled, refBodyId, [], [], propNames, [], celBodyData, false);
                else
                    [depVarValue, depVarUnit] = lvd_getDepVarValueUnit(1, stateLogEntry, taskStr, refBodyId, celBodyData, false, obj.extrema.frame);
                end
                
                if(isempty(obj.value))
                    obj.value = depVarValue;
                else
                    if(obj.extrema.type == LaunchVehicleExtremaTypeEnum.Maximum)
                        if(isnan(prevValue) || prevValue < depVarValue)
                            obj.value = depVarValue;
                        else
                            obj.value = prevValue;
                        end
                    elseif(obj.extrema.type == LaunchVehicleExtremaTypeEnum.Minimum)
                        if(isnan(prevValue) || prevValue > depVarValue)
                            obj.value = depVarValue;
                        else
                            obj.value = prevValue;
                        end
                    end
                end
                
                newValue = obj.value;

                if(isempty(obj.extrema.unitStr))
                    obj.extrema.unitStr = depVarUnit;
                end
            else
                newValue = obj.value;
            end
        end
    end
    
    methods(Access=protected)
        function copyObj = copyElement(obj)
            copyObj = copyElement@matlab.mixin.Copyable(obj);
            
            for(i=1:length(obj))
                copyObj(i).extrema = obj(i).extrema;
            end
        end
    end
end