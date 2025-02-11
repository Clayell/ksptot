classdef LvdOptimization < matlab.mixin.SetGet
    %LvdOptimization Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        lvdData LvdData
        
        vars OptimizationVariableSet
%         objFcn(1,1) AbstractObjectiveFcn = NoOptimizationObjectiveFcn()
        objFcn(1,1) AbstractObjectiveFcn = CompositeObjectiveFcn()
        constraints(1,1) ConstraintSet =  ConstraintSet()
        
        %Optimization Algo Selection
        optAlgo(1,1) LvdOptimizerAlgoEnum = LvdOptimizerAlgoEnum.Fmincon;
        
        %Optimizers
        fminconOpt(1,1) FminconOptimizer = FminconOptimizer();
        patternSearchOpt(1,1) PatternSearchOptimizer = PatternSearchOptimizer();
        nomadOpt(1,1) NomadOptimizer = NomadOptimizer();
        ipoptOpt(1,1) IpOptOptimizer = IpOptOptimizer();
        surragateOpt(1,1) SurrogateOptimizer = SurrogateOptimizer();
        sqpOpt(1,1) SQPOptimizer = SQPOptimizer();
        
        %Gradient Calc Algo Selection
        gradAlgo(1,1) LvdOptimizerGradientCalculationAlgoEnum = LvdOptimizerGradientCalculationAlgoEnum.BuiltIn;

        %Gradient Calculation Algos
        builtInGradMethod(1,1) BuiltInGradientCalculationMethod = BuiltInGradientCalculationMethod();
        customFiniteDiffsCalcMethod(1,1) CustomFiniteDiffsCalculationMethod = CustomFiniteDiffsCalculationMethod();
        derivEstFiniteDiffCalcMethod(1,1) DERIVEstFiniteDiffsCalculationMethod = DERIVEstFiniteDiffsCalculationMethod();
    end
    
    methods
        function obj = LvdOptimization(lvdData)
            obj.lvdData = lvdData;
            
            obj.vars = OptimizationVariableSet(obj.lvdData);
            obj.objFcn = CompositeObjectiveFcn(GenericObjectiveFcn.empty(1,0), ObjFcnDirectionTypeEnum.Minimize, ObjFcnCompositeMethodEnum.Sum, lvdData.optimizer, lvdData);
            obj.constraints = ConstraintSet(obj, lvdData);
            
            obj.optAlgo = LvdOptimizerAlgoEnum.Fmincon;
            obj.fminconOpt = FminconOptimizer();
            obj.patternSearchOpt = PatternSearchOptimizer();
            obj.nomadOpt = NomadOptimizer();
            obj.ipoptOpt = IpOptOptimizer();
            obj.surragateOpt = SurrogateOptimizer();
            
            obj.builtInGradMethod = BuiltInGradientCalculationMethod();
            obj.customFiniteDiffsCalcMethod = CustomFiniteDiffsCalculationMethod();
        end
        
        function [exitflag, message] = optimize(obj, writeOutput, callOutputFcn, hLvdMainGUI)     
            obj.vars.removeUselessVars();
            obj.vars.sortVarsByEvtNum();
            optimizer = obj.getSelectedOptimizer();

            [x0All, actVars, ~] = obj.vars.getTotalScaledXVector();

            if(isempty(x0All) && isempty(actVars))
                uialert(hLvdMainGUI, 'There are no optimization variables enabled in this mission.  Optimization requires at least one variable.  Please enable at least one variable to continue with optimization.', 'Launch Vehicle Designer', 'Icon','error');

                return;
            end

            [exitflag, message] = optimizer.optimize(obj, writeOutput, callOutputFcn, hLvdMainGUI);
        end
        
        function [exitflag, message] = consoleOptimize(obj)
            global options_gravParamType %#ok<GVMIS> 
            
            if(isempty(options_gravParamType))
                options_gravParamType = 'kspStockLike';
            end
            
            writeOutput = @(varargin) disp('');
            callOutputFcn = false;
            
            [exitflag, message] = obj.optimize(writeOutput, callOutputFcn, []);
        end
        
        function optimizer = getSelectedOptimizer(obj)
            optAlgorithm = obj.optAlgo;
            optimizer = obj.getOptimizerForEnum(optAlgorithm);
        end
        
        function optimizer = getOptimizerForEnum(obj, optAlgorithm)
            if(optAlgorithm == LvdOptimizerAlgoEnum.Fmincon)
                optimizer = obj.fminconOpt;
            elseif(optAlgorithm == LvdOptimizerAlgoEnum.PatternSearch)
                optimizer = obj.patternSearchOpt;
            elseif(optAlgorithm == LvdOptimizerAlgoEnum.Nomad)
                optimizer = obj.nomadOpt;
            elseif(optAlgorithm == LvdOptimizerAlgoEnum.Ipopt)
                optimizer = obj.ipoptOpt;
            elseif(optAlgorithm == LvdOptimizerAlgoEnum.Surrogate)
                optimizer = obj.surragateOpt;
            elseif(optAlgorithm == LvdOptimizerAlgoEnum.SQP)
                optimizer = obj.sqpOpt;
            else
                error('Unknown LVD optimization algorithm!');
            end
        end
        
        function gradAlgo = getGradAlgoForEnum(obj, gradAlgoEnum)
            if(gradAlgoEnum == LvdOptimizerGradientCalculationAlgoEnum.BuiltIn)
                gradAlgo = obj.builtInGradMethod;
            elseif(gradAlgoEnum == LvdOptimizerGradientCalculationAlgoEnum.FiniteDifferences)
                gradAlgo = obj.customFiniteDiffsCalcMethod;
            else
                error('Unknown LVD gradient algorithm!');
            end
        end
        
        function tf = usesParallel(obj)
            tf = obj.getSelectedOptimizer().usesParallel();
        end
        
        function tf = usesStage(obj, stage)
            tf = obj.objFcn.usesStage(stage);
            
            tf = tf || obj.constraints.usesStage(stage);
        end
        
        function tf = usesEngine(obj, engine)
            tf = obj.objFcn.usesEngine(engine);
            
            tf = tf || obj.constraints.usesEngine(engine);
        end
        
        function tf = usesTank(obj, tank)
            tf = obj.objFcn.usesTank(tank);
            
            tf = tf || obj.constraints.usesTank(tank);
        end
        
        function tf = usesEngineToTankConn(obj, engineToTank)
            tf = obj.objFcn.usesEngineToTankConn(engineToTank);
            
            tf = tf || obj.constraints.usesEngineToTankConn(engineToTank);
        end
        
        function tf = usesExtremum(obj, extremum)
            tf = obj.objFcn.usesExtremum(extremum);
            
            tf = tf || obj.constraints.usesExtremum(extremum);
        end
        
        function tf = usesGroundObj(obj, grdObj)
            tf = obj.objFcn.usesGroundObj(grdObj) || obj.constraints.usesGroundObj(grdObj);
        end
        
        function tf = usesCalculusCalc(obj, calculusCalc)
            tf = obj.objFcn.usesCalculusCalc(calculusCalc);
            
            tf = tf || obj.constraints.usesCalculusCalc(calculusCalc);
        end
        
        function tf = usesGeometricPoint(obj, point)
            tf = obj.constraints.usesGeometricPoint(point);
        end
        
        function tf = usesGeometricVector(obj, vector)
            tf = obj.constraints.usesGeometricVector(vector);
        end
        
        function tf = usesGeometricCoordSys(obj, coordSys)
            tf = obj.constraints.usesGeometricCoordSys(coordSys);
        end
        
        function tf = usesGeometricRefFrame(obj, refFrame)
            tf = obj.constraints.usesGeometricRefFrame(refFrame);
        end
        
        function tf = usesGeometricAngle(obj, angle)
            tf = obj.constraints.usesGeometricAngle(angle);
        end
        
        function tf = usesGeometricPlane(obj, plane)
            tf = obj.constraints.usesGeometricPlane(plane);
        end 
        
        function tf = usesPlugin(obj, plugin)
            tf = obj.constraints.usesPlugin(plugin);
        end 
    end
    
    methods(Static)
        function obj = loadobj(obj)
            if(isempty(obj.vars.lvdData))
                obj.vars.lvdData = obj.lvdData;
            end
        end        
    end
    
    methods(Access=private)
        function evtNumToStartScriptExecAt = getEvtNumToStartScriptExecAt(obj, actVars)
            evtNumToStartScriptExecAt = obj.lvdData.script.getTotalNumOfEvents();
            for(i=1:length(actVars)) %#ok<*NO4LP>
                var = actVars(i);
                
                if(isVarInLaunchVehicle(var, obj.lvdData))
                    varEvtNum = 1;
                else
                    varEvtNum = getEventNumberForVar(var, obj.lvdData);
                    
                    if(isempty(varEvtNum))
                        varEvtNum = 1;
                    end
                end
                
                if(varEvtNum < evtNumToStartScriptExecAt)
                    evtNumToStartScriptExecAt = varEvtNum;
                end
                
                if(evtNumToStartScriptExecAt == 1)
                    break; %it can't go lower than 1, so we're executing the whole thing.  No reason to keep going.
                end
            end
        end
        
        function evtNumToEndScriptExecAt = getEvtNumToEndScriptExecAt(obj)
            [~, activeVars, ~, ~] = obj.vars.getTotalScaledXVector();
            
            evtNumToEndScriptExecAt = -1;
            for(i=1:length(activeVars))
                var = activeVars(i);
                
                if(isVarInLaunchVehicle(var, obj.lvdData))
                    varEvtNum = 1;
                else
                    varEvtNum = getEventNumberForVar(var, obj.lvdData);
                    
                    if(isempty(varEvtNum))
                        varEvtNum = 1;
                    end
                end
                
                if(varEvtNum > evtNumToEndScriptExecAt)
                    evtNumToEndScriptExecAt = varEvtNum;
                end
            end
            
            objFcnEvts = obj.objFcn.getObjFuncEvents();
            for(i=1:length(objFcnEvts))
                objFcnEvtNum = objFcnEvts(i).getEventNum();
                
                if(objFcnEvtNum > evtNumToEndScriptExecAt)
                    evtNumToEndScriptExecAt = objFcnEvtNum;
                end
            end
            
            constrEvts = obj.constraints.getConstrEvents();
            for(i=1:length(constrEvts))
                constrEvtNum = constrEvts(i).getEventNum();
                
                if(constrEvtNum > evtNumToEndScriptExecAt)
                    evtNumToEndScriptExecAt = constrEvtNum;
                end
            end
        end
    end
end