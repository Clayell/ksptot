classdef CelestialBodyData < matlab.mixin.SetGet & dynamicprops
    %CelestialBodyData Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access=private)
        bodies(1,:) KSPTOT_BodyInfo
        
        bodyIdCacheArr(1,:) double = [];
        
        ci CelestialBodyIntegration
    end
    
    properties(Transient,Access=private)
        topLvlBodyCache KSPTOT_BodyInfo
    end
    
    properties(Constant)
        emptyBodyInfo KSPTOT_BodyInfo = KSPTOT_BodyInfo.empty(1,0);
        globalBaseFrame GlobalBaseInertialFrame = GlobalBaseInertialFrame();
        numIntBlockSize(1,1) double = 1000*86400;
    end
    
    methods
        function obj = CelestialBodyData(celBodyData)
            if(isstruct(celBodyData))
                bodyNameFields = fields(celBodyData);
                
                for(i=1:length(bodyNameFields)) %#ok<*NO4LP> 
                    bodyName = bodyNameFields{i};
                    
                    if(not(isprop(obj,bodyName)))
                        addprop(obj,bodyName);
                        bodyInfo = celBodyData.(bodyName);
                        
                        obj.(bodyName) = bodyInfo;
                        obj.bodies(end+1) = bodyInfo;
                    else
                        error('The following body already exists in CelestialBodyData when trying to instantiate the class from the celestial body data structure: %s', bodyName);
                    end
                end
                
            elseif(isa(celBodyData,'CelestialBodyData'))
                obj = celBodyData;
                
            else
                error('Input to CelestialBodyData must be the structure representation of celestial body data.');
            end
            
            for(i=1:length(obj.bodies))
                if(isstruct(obj.bodies(i).celBodyData) || isempty(obj.bodies(i).celBodyData))
                    obj.bodies(i).celBodyData = obj;
                end
            end
            
            obj.bodyIdCacheArr = [obj.bodies.id];
            
            obj.ci = CelestialBodyIntegration(obj);

            if(any([obj.bodies.propTypeIsNumerical]))
                obj.ci.integrateCelestialBodies(0, obj.numIntBlockSize);
            end
        end
        
        function resetAllParentNeedsUpdateFlags(obj)
            for(i=1:length(obj.bodies))
                obj.bodies(i).parentBodyInfoNeedsUpdate = true;
            end
        end
        
        function bodyInfo = getBodyInfoById(obj, bodyId)
%             arr = [obj.bodies.id];
            bodyInfo = obj.bodies(obj.bodyIdCacheArr == bodyId);
            
            if(numel(bodyInfo) > 1)
                bodyInfo = bodyInfo(1);
            end
        end
        
        function [minUt, maxUt] = getStateCacheMinUtMaxUt(obj)
            bool = [obj.bodies.propTypeEnum] == BodyPropagationTypeEnum.Numerical;
            numericBodies = obj.bodies(bool);
            
            if(numel(numericBodies) >= 1)
                numericBody = numericBodies(1);
                times = numericBody.numIntStateCache.times;
                minUt = min(times);
                maxUt = max(times);
            else
                minUt = 0;
                maxUt = 0;
            end
        end
        
        function updateCelestialBodyStateCache(obj, minUT, maxUT, hWaitbar)
            arguments
                obj(1,1) CelestialBodyData
                minUT(1,1) double
                maxUT(1,1) double
                hWaitbar = [];
            end

            obj.ci.integrateCelestialBodies(minUT, maxUT, hWaitbar);
        end
        
        %Override the following structure methods for backwards
        %compatibility with structure celBodyData
        function f = fields(obj)
            f = {};
            
            for(i=1:length(obj.bodies))
                f{end+1} = lower(obj.bodies(i).name); %#ok<AGROW>
            end
            
            f = f(:);
        end
        
        function f = fieldnames(obj)
            f = obj.fields();
        end
        
        function tf = isfield(obj,field)
            tf = isprop(obj,field);
        end
        
        function allBodyInfo = getAllBodyInfo(obj)
            allBodyInfo = obj.bodies;
        end
        
        function [listBoxStr, bodyInfos] = getListboxStr(obj)
            listBoxStr = {};
            
            for(i=1:length(obj.bodies))
                listBoxStr{end+1} = obj.bodies(i).name; %#ok<AGROW>
            end
            
            bodyInfos = obj.bodies;
        end
        
        function topLvlBody = getTopLevelBody(obj)
            if(isempty(obj.topLvlBodyCache))
                obj.topLvlBodyCache = getTopLevelCentralBody(obj);
            end
            
            topLvlBody = obj.topLvlBodyCache;
        end
        
        function bodies = getAllBodiesWithChildren(obj)
            bodies = KSPTOT_BodyInfo.empty(1,0);
            for(i=1:length(obj.bodies))
                bodyInfo = obj.bodies(i);
                
                cBodies = bodyInfo.getChildrenBodyInfo(obj);
                if(not(isempty(cBodies)))
                    bodies(end+1) = bodyInfo; %#ok<AGROW> 
                end
            end
        end
    end
    
    methods(Static)
        function obj = loadobj(obj)
            obj.bodyIdCacheArr = [obj.bodies.id];
            
            if(isprop(obj,'sun'))
                obj.topLvlBodyCache = getTopLevelCentralBody(obj);
            end
            
            if(isempty(obj.ci))
                obj.ci = CelestialBodyIntegration(obj);
                obj.ci.integrateCelestialBodies(0, obj.numIntBlockSize);
            end
        end
    end
end

