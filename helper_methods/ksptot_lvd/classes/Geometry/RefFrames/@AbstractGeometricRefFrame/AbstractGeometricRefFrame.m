classdef AbstractGeometricRefFrame < matlab.mixin.SetGet & matlab.mixin.Heterogeneous
    %AbstractGeometricRefFrame Summary of this class goes here
    %   Detailed explanation goes here
       
    properties
        %drawing
        scaleFactor = 100; %km
        
        %x-axis
        xAxisColor = ColorSpecEnum.Red
        xAxisLineSpec = LineSpecEnum.SolidLine
        xAxisLineWidth = 2
        
        %y-axis
        yAxisColor = ColorSpecEnum.Green
        yAxisLineSpec = LineSpecEnum.SolidLine
        yAxisLineWidth = 2
        
        %z-axis
        zAxisColor = ColorSpecEnum.Blue
        zAxisLineSpec = LineSpecEnum.SolidLine
        zAxisLineWidth = 2
    end
    
    methods         
        [posOffsetOrigin, velOffsetOrigin, angVelWrtOrigin, rotMatToInertial] = getRefFrameAtTime(obj, time, vehElemSet, inFrame)

        [angVelWrtOrigin, rotMatToInertial] = getAngVelWrtOriginAndRotMatToInertial(obj, time, vehElemSet, bodyInfoInertialOrigin)

        rotMatToInertial = getRotMatToInertialAtTime(obj, time, vehElemSet, inFrame)

        tf = frameOriginIsACelBody(obj)
        
        name = getName(obj)
        
        setName(obj, name)
        
        listboxStr = getListboxStr(obj)
        
        useTf = openEditDialog(obj)
        
        tf = isVehDependent(obj)
        
        tf = originIsVehDependent(obj)
        
        tf = usesGroundObj(obj, groundObj)
        
        tf = usesGeometricPoint(obj, point)
        
        tf = usesGeometricVector(obj, vector)
        
        tf = usesGeometricCoordSys(obj, coordSys)
        
        tf = usesGeometricRefFrame(obj, refFrame)
        
        tf = usesGeometricAngle(~, ~)
        
        tf = usesGeometricPlane(~, ~)
        
        tf = isInUse(obj, lvdData)
    end
    
    methods(Sealed)
        function tf = eq(a,b)
            tf = eq@handle(a,b);
        end
        
        function tf = ne(a,b)
            tf = ne@handle(a,b);
        end
    end
end