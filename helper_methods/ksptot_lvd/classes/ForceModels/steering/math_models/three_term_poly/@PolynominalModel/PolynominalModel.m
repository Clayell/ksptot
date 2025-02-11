classdef PolynominalModel < matlab.mixin.SetGet
    %PolynominalModel Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        t0(1,1) double = 0;
        constTerm(1,1) double = 0;
        linearTerm(1,1) double = 0;
        accelTerm(1,1) double = 0;
        
        tOffset(1,1) double = 0;
    end
    
    methods
        function obj = PolynominalModel(t0, constTerm, linearTerm, accelTerm)
            obj.t0 = t0;
            obj.constTerm = real(constTerm);
            obj.linearTerm = real(linearTerm);
            obj.accelTerm = real(accelTerm);
        end
        
        function value = getValueAtTime(obj,ut)
            dt = (ut - obj.t0) + obj.tOffset;
            
            value = obj.constTerm + dt*obj.linearTerm + (1/2)*obj.accelTerm*dt^2;
        end
        
        function newPolyModel = deepCopy(obj)
            newPolyModel = PolynominalModel(obj.t0, obj.constTerm, obj.linearTerm, obj.accelTerm);
        end
    end
end