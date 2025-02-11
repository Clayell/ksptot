classdef GraphicalAnalysisTask < matlab.mixin.SetGet
    %GraphicalAnalysisTask Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        taskStr(1,:) char
        frame AbstractReferenceFrame
    end
    
    methods
        function obj = GraphicalAnalysisTask(taskStr, frame)
            obj.taskStr = taskStr;
            obj.frame = frame;
        end
        
        function listboxStr = getListBoxStr(obj)
            startInd = regexp(obj.taskStr, '^.+ \[.+]', 'once');
            if(not(isempty(startInd)))
                listboxStr = sprintf('%s', obj.taskStr);
            else
                listboxStr = sprintf('%s [%s]', obj.taskStr, obj.frame.getNameStr());
            end
        end
        
        function lblStr = getAxisLabel(obj)
            tokens = regexp(obj.taskStr, '^.+ (\[.+\])', 'tokens');
            if(not(isempty(tokens)))
                tokens = tokens{1}{1};
            else
                tokens = [];
            end
            
            if(not(isempty(tokens)))
                newTaskStr = strrep(obj.taskStr,tokens,'');
                
                startInd = regexp(newTaskStr,' \"$');
                if(not(isempty(startInd)))
                    newTaskStr(startInd) = '';
                end
                
                lblStr = {newTaskStr, tokens};
            else
                lblStr = {sprintf(obj.taskStr), obj.frame.getNameStr()};
            end
        end
        
        function [depVarValue, depVarUnit, prevDistTraveled] = executeTask(obj, lvdStateLogEntry, maTaskList, prevDistTraveled, otherSCId, stationID, propNames, celBodyData)                        
            refBodyId = obj.frame.getOriginBody().id;
            
            if(ismember(obj.taskStr,maTaskList))
                maStateLogEntry = lvdStateLogEntry.getMAFormattedStateLogMatrix(true);
                [depVarValue, depVarUnit, prevDistTraveled] = ma_getDepVarValueUnit(1, maStateLogEntry, obj.taskStr, prevDistTraveled, refBodyId, otherSCId, stationID, propNames, [], celBodyData, false);
                
            else
                [depVarValue, depVarUnit] = lvd_getDepVarValueUnit(1, lvdStateLogEntry, obj.taskStr, refBodyId, celBodyData, false, obj.frame);
            end
        end
        
        function tf = usesGeometricRefFrame(obj, refFrame)
            if(obj.frame.typeEnum == ReferenceFrameEnum.UserDefined)
                tf = obj.frame.geometricFrame.usesGeometricRefFrame(refFrame);
            else
                tf = false;
            end
        end
    end
end