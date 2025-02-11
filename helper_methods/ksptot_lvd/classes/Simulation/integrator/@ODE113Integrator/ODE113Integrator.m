classdef ODE113Integrator < AbstractFirstOrderIntegrator
    %ODE45Integrator Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        options(1,1) BuiltInIntegratorOptions = BuiltInIntegratorOptions();
        integratorEnum = IntegratorEnum.ODE113;
    end
    
    methods
        function obj = ODE113Integrator(options)
            if(nargin > 0)
                obj.options = options;
            else
                obj.options = BuiltInIntegratorOptions();
            end
        end
        
        function [t,y,te,ye,ie] = integrate(obj, odefun, tspan, y0, evtsFunc, odeOutputFun)
            odeSetOptions = obj.options.getIntegratorOptions();
            optionsToUse = odeset(odeSetOptions, 'Events',evtsFunc, 'OutputFcn',odeOutputFun);
            
            [t,y,te,ye,ie] = ode113(odefun, tspan, y0, optionsToUse);
        end
        
        function options = getOptions(obj)
            options = obj.options;
        end
    end
end