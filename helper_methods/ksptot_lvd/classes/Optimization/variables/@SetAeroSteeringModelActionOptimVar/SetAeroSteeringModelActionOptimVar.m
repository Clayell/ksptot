classdef SetAeroSteeringModelActionOptimVar < AbstractOptimizationVariable
    %SetAeroSteeringModelActionOptimVar Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        varObj = AeroAnglesPolySteeringModel.getDefaultSteeringModel()
        
        lb(1,10) double = zeros([1,10]);
        ub(1,10) double = zeros([1,10]);
        
        varBankConst(1,1) logical = false;
        varBankLin(1,1) logical   = false;
        varBankAccel(1,1) logical = false;
        
        varAoAConst(1,1) logical = false;
        varAoALin(1,1) logical   = false;
        varAoAAccel(1,1) logical = false;
        
        varSlipConst(1,1) logical = false;
        varSlipLin(1,1) logical   = false;
        varSlipAccel(1,1) logical = false;
        
        varTimeOffset(1,1) logical = false;
    end
    
    methods
        function obj = SetAeroSteeringModelActionOptimVar(varObj)
            obj.varObj = varObj;
            obj.varObj.optVar = obj;
            
            obj.id = rand();
        end
        
        function x = getXsForVariable(obj)
            x = NaN(1,10);
            
            if(obj.varBankConst)
                x(1) = obj.varObj.bankModel.constTerm;
            end
            if(obj.varBankLin)
                x(2) = obj.varObj.bankModel.linearTerm;
            end
            if(obj.varBankAccel)
                x(3) = obj.varObj.bankModel.accelTerm;
            end
            
            if(obj.varAoAConst)
                x(4) = obj.varObj.aoAModel.constTerm;
            end
            if(obj.varAoALin)
                x(5) = obj.varObj.aoAModel.linearTerm;
            end
            if(obj.varAoAAccel)
                x(6) = obj.varObj.aoAModel.accelTerm;
            end
            
            if(obj.varSlipConst)
                x(7) = obj.varObj.slipModel.constTerm;
            end
            if(obj.varSlipLin)
                x(8) = obj.varObj.slipModel.linearTerm;
            end
            if(obj.varSlipAccel)
                x(9) = obj.varObj.slipModel.accelTerm;
            end
            
            if(obj.varTimeOffset)
                x(10) = obj.varObj.slipModel.tOffset; %this applies for all angle models
            end
            
            x(isnan(x)) = [];
        end
        
        function [lb, ub] = getBndsForVariable(obj)
            useTf = obj.getUseTfForVariable();

            lb = obj.lb(useTf);
            ub = obj.ub(useTf);
        end
        
        function [lb, ub] = getAllBndsForVariable(obj)
            lb = obj.lb;
            ub = obj.lb;
        end
        
        function setBndsForVariable(obj, lb, ub)
            if(length(lb) == 10 && length(ub) == 10)
                obj.lb = lb;
                obj.ub = ub;
            else
                useTf = obj.getUseTfForVariable();

                obj.lb(useTf) = lb;
                obj.ub(useTf) = ub;
            end
        end
        
        function useTf = getUseTfForVariable(obj)
            useTf = [obj.varBankConst  obj.varBankLin    obj.varBankAccel ...
                     obj.varAoAConst  obj.varAoALin    obj.varAoAAccel ...
                     obj.varSlipConst  obj.varSlipLin    obj.varSlipAccel ...
                     obj.varTimeOffset];
                 
            useTf = logical(useTf);
        end
        
        function setUseTfForVariable(obj, useTf)                 
            obj.varBankConst = useTf(1);
            obj.varBankLin = useTf(2);
            obj.varBankAccel = useTf(3);
            
            obj.varAoAConst = useTf(4);
            obj.varAoALin = useTf(5);
            obj.varAoAAccel = useTf(6);
            
            obj.varSlipConst = useTf(7);
            obj.varSlipLin = useTf(8);
            obj.varSlipAccel = useTf(9);
            
            obj.varTimeOffset = useTf(10);
        end
        
        function updateObjWithVarValue(obj, x)
            ind = 1;
            
            if(obj.varBankConst)
                obj.varObj.bankModel.constTerm = x(ind);
                ind = ind + 1;
            end
            if(obj.varBankLin)
                obj.varObj.bankModel.linearTerm = x(ind);
                ind = ind + 1;
            end
            if(obj.varBankAccel)
                obj.varObj.bankModel.accelTerm = x(ind);
                ind = ind + 1;
            end
            
            if(obj.varAoAConst)
                obj.varObj.aoAModel.constTerm = x(ind);
                ind = ind + 1;
            end
            if(obj.varAoALin)
                obj.varObj.aoAModel.linearTerm = x(ind);
                ind = ind + 1;
            end
            if(obj.varAoAAccel)
                obj.varObj.aoAModel.accelTerm = x(ind);
                ind = ind + 1;
            end
            
            if(obj.varSlipConst)
                obj.varObj.slipModel.constTerm = x(ind);
                ind = ind + 1;
            end
            if(obj.varSlipLin)
                obj.varObj.slipModel.linearTerm = x(ind);
                ind = ind + 1;
            end
            if(obj.varSlipAccel)
                obj.varObj.slipModel.accelTerm = x(ind);
                ind = ind + 1;
            end
            
            if(obj.varTimeOffset)
                obj.varObj.slipModel.tOffset = x(ind);
                obj.varObj.aoAModel.tOffset = x(ind);
                obj.varObj.bankModel.tOffset = x(ind);
                ind = ind + 1; %#ok<NASGU>
            end
        end
        
        function nameStrs = getStrNamesOfVars(obj, evtNum, varLocType)
           if(evtNum > 0)
                subStr = sprintf('Event %i',evtNum);
            else
                subStr = varLocType;
            end
            
            nameStrs = {sprintf('%s Bank Angle Constant', subStr), ...
                        sprintf('%s Bank Angle Rate', subStr), ...
                        sprintf('%s Bank Angle Acceleration', subStr), ...
                        sprintf('%s AoA Constant', subStr), ...
                        sprintf('%s AoA Rate', subStr), ...
                        sprintf('%s AoA Acceleration', subStr), ...
                        sprintf('%s Side Slip Constant', subStr), ...
                        sprintf('%s Side Slip Rate', subStr), ...
                        sprintf('%s Side Slip Acceleration', subStr), ...
                        sprintf('%s Steering Time Offset', subStr)};
                    
            nameStrs = nameStrs(obj.getUseTfForVariable());
        end

        function varsStoredInRad = getVarsStoredInRad(obj)
            varsStoredInRad = [true true true  true true true  true true true false];
        end
    end
end