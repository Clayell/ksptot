classdef ForceModelsEnum < matlab.mixin.SetGet & matlab.mixin.Heterogeneous
    %ForceModelsEnum Summary of this class goes here
    %   Detailed explanation goes here
    
    enumeration
        Gravity('Gravity',GravityForceModel(), false, true, false);
        Drag('Drag Force',DragForceModel(), true, false, true);
        Thrust('Thrust',ThrustForceModel(), true, false, true);
        Normal('Normal Force',NormalForceModel(), true, false, false);
        Lift('Lift Force',LiftForceModel(), true, false, true);
        Gravity3rdBody('3rd Body Gravity',Gravity3rdBodyForceModel(), true, true, false);
        SolarRadPress('Solar Radiation Pressure',SolarRadPressForceModel, true, false, true);
    end
    
    properties
        name char
        model AbstractForceModel
        canBeDisabled(1,1) logical = false;
        allowedForSecondOrder(1,1) logical = false;
        usesAttitudeState(1,1) logical
    end
    
    methods
        function obj = ForceModelsEnum(name, model, canBeDisabled, allowedForSecondOrder, usesAttitudeState)
            obj.name = name;
            obj.model = model;
            obj.canBeDisabled = canBeDisabled;
            obj.allowedForSecondOrder = allowedForSecondOrder;
            obj.usesAttitudeState = usesAttitudeState;
        end
    end
    
    methods(Static)    
        function m = getEnumsOfDisablableForceModels()
            [m,~] = enumeration('ForceModelsEnum');
            m = m([m.canBeDisabled]);
        end
        
        function listBoxStrs = getListBoxStrs()
            [m,~] = enumeration('ForceModelsEnum');
            
            listBoxStrs = {};
            for(i=1:length(m)) %#ok<*NO4LP>
                listBoxStrs{end+1} = m(i).name; %#ok<AGROW>
            end
        end
        
        function listBoxStrs = getListBoxStrsOfDisablableModels()
            m = ForceModelsEnum.getEnumsOfDisablableForceModels();
            
            listBoxStrs = {};
            for(i=1:length(m)) %#ok<*NO4LP>
                listBoxStrs{end+1} = m(i).name; %#ok<AGROW>
            end
        end
        
        function [ind, fmE] = getIndOfListboxStrsForModel(model)
            [m,~] = enumeration('ForceModelsEnum');
            
            ind = -1;
            for(i=1:length(m))
                if(strcmpi(class(m(i).model),class(model)))
                    ind = i;
                    fmE = m(i);
                    break;
                end
            end
        end
        
        function [ind, fmE] = getIndOfDisablableListboxStrsForModel(model)
            m = ForceModelsEnum.getEnumsOfDisablableForceModels();
            
            ind = -1;
            for(i=1:length(m))
                if(strcmpi(class(m(i).model),class(model)))
                    ind = i;
                    fmE = m(i);
                    break;
                end
            end
        end
        
        function fmArr = getDefaultArrayOfForceModelEnums()
            fmArr = [ForceModelsEnum.Gravity, ForceModelsEnum.Drag, ForceModelsEnum.Thrust];
        end
        
        function fmArr = getAllForceModelsThatCannotBeDisabled()
            [m,~] = enumeration('ForceModelsEnum');
            
            fmArr = ForceModelsEnum.empty(1,0);
            for(i=1:length(m))
                if(m(i).canBeDisabled == false)
                    fmArr(end+1) = m(i); %#ok<AGROW>
                end
            end
        end
    end
end

