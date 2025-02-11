classdef ParallelToFrameCoordSystem < AbstractGeometricCoordSystem
    %ParallelToFrameCoordSystem Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        frame AbstractReferenceFrame
        
        name(1,:) char
        lvdData LvdData
    end
    
    methods        
        function obj = ParallelToFrameCoordSystem(frame, name, lvdData)
            obj.frame = frame;
            
            obj.name = name;
            obj.lvdData = lvdData;
        end
        
        function [rotMatToInertial] = getCoordSysAtTime(obj, time, vehElemSet, ~)
            [~, ~, ~, rotMatToInertial] = obj.frame.getOffsetsWrtInertialOrigin(time, vehElemSet);
        end
        
        function name = getName(obj)
            name = obj.name;
        end
        
        function setName(obj, name)
            obj.name = name;
        end
        
        function listboxStr = getListboxStr(obj)
            listboxStr = sprintf('%s (Parallel To "%s")', obj.getName(), obj.frame.getNameStr());
        end
        
        function useTf = openEditDialog(obj)
%             useTf = lvd_EditParallelToFrameCoordSysGUI(obj, obj.lvdData);
            
            output = AppDesignerGUIOutput({false});
            lvd_EditParallelToFrameCoordSysGUI_App(obj, obj.lvdData, output);
            useTf = output.output{1};
        end
        
        function tf = isVehDependent(obj)
            if(obj.frame.typeEnum == ReferenceFrameEnum.UserDefined)
                tf = obj.frame.geometricFrame.isVehDependent();
            else
                tf = false;
            end
        end
        
        function tf = usesGroundObj(obj, groundObj)
            tf = obj.frame.usesGroundObj(groundObj);
        end
        
        function tf = usesGeometricPoint(obj, point)
            if(obj.frame.typeEnum == ReferenceFrameEnum.UserDefined)
                tf = obj.frame.geometricFrame.usesGeometricPoint(point);
            else
                tf = false;
            end
        end
        
        function tf = usesGeometricVector(obj, vector)
            if(obj.frame.typeEnum == ReferenceFrameEnum.UserDefined)
                tf = obj.frame.geometricFrame.usesGeometricVector(vector);
            else
                tf = false;
            end
        end
        
        function tf = usesGeometricCoordSys(obj, coordSys)
            if(obj.frame.typeEnum == ReferenceFrameEnum.UserDefined)
                tf = obj.frame.geometricFrame.usesGeometricCoordSys(coordSys);
            else
                tf = false;
            end
        end
        
        function tf = usesGeometricRefFrame(obj, refFrame)
            if(obj.frame.typeEnum == ReferenceFrameEnum.UserDefined)
                tf = obj.frame.geometricFrame.usesGeometricRefFrame(refFrame);
            else
                tf = false;
            end
        end
        
        function tf = usesGeometricAngle(obj, angle)
            if(obj.frame.typeEnum == ReferenceFrameEnum.UserDefined)
                tf = obj.frame.geometricFrame.usesGeometricAngle(angle);
            else
                tf = false;
            end
        end 
        
        function tf = usesGeometricPlane(obj, plane)
            if(obj.frame.typeEnum == ReferenceFrameEnum.UserDefined)
                tf = obj.frame.geometricFrame.usesGeometricPlane(plane);
            else
                tf = false;
            end
        end 
        
        function tf = isInUse(obj, lvdData)
            tf = lvdData.usesGeometricCoordSys(obj);
        end
    end
end