classdef FminconOptimizer < AbstractGradientOptimizer
    %FminconOptimizer Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        options(1,1) FminconOptions = FminconOptions();
    end
    
    methods
        function obj = FminconOptimizer()
            obj.options = FminconOptions();
        end
        
        function [exitflag, message] = optimize(obj, lvdOpt, writeOutput, callOutputFcn, hLvdMainGUI)
            [x0All, actVars, varNameStrs] = lvdOpt.vars.getTotalScaledXVector();
            [lbAll, ubAll, lbUsAll, ubUsAll] = lvdOpt.vars.getTotalScaledBndsVector();
            typicalX = lvdOpt.vars.getTypicalScaledXVector();
            
            if(isempty(x0All) && isempty(actVars))
                exitflag = 0;
                message = 'No variables enabled on script.  Aborting optimization.';

                return;
            end
            
            bool = x0All < lbAll;
            x0All(bool) = lbAll(bool);
            
            bool = x0All > ubAll;
            x0All(bool) = ubAll(bool);
            
            evtNumToStartScriptExecAt = obj.getEvtNumToStartScriptExecAt(lvdOpt, actVars);
            evtToStartScriptExecAt = lvdOpt.lvdData.script.getEventForInd(evtNumToStartScriptExecAt);
            
            opts = obj.options.getOptionsForOptimizer(typicalX);

            objFuncWrapper = @(x) lvdOpt.objFcn.evalObjFcn(x, evtToStartScriptExecAt);

            if(opts.SpecifyConstraintGradient)
                nonlcon = @(x) lvdOpt.constraints.evalConstraintsWithGradients(x, true, evtToStartScriptExecAt, true, []);
            else
                nonlcon = @(x) lvdOpt.constraints.evalConstraints(x, true, evtToStartScriptExecAt, true, []);
            end
                            
            if(obj.options.computeOptimalStepSizes == true)
                optimalStepSizes = CustomFiniteDiffsCalculationMethod.determineOptimalStepSizes(@(x) CustomFiniteDiffsCalculationMethod.combinedConstrFun(x, lvdOpt.lvdData), x0All, hLvdMainGUI);
                
                if(not(isempty(optimalStepSizes)))
                    opts.FiniteDifferenceStepSize = optimalStepSizes;
                    opts.TypicalX = ones(length(optimalStepSizes),1);
                end
            end
            
            if(lvdOpt.gradAlgo == LvdOptimizerGradientCalculationAlgoEnum.BuiltIn)
                objFunToPass = objFuncWrapper;
                opts = optimoptions(opts, 'SpecifyObjectiveGradient',false);
            elseif(lvdOpt.gradAlgo == LvdOptimizerGradientCalculationAlgoEnum.FiniteDifferences)
                gradCalcMethod = lvdOpt.customFiniteDiffsCalcMethod;
                objFunToPass = @(x) obj.objFuncWithGradient(objFuncWrapper, x, gradCalcMethod, obj.usesParallel());
                opts = optimoptions(opts, 'SpecifyObjectiveGradient',true);
                
                sparsityTF = gradCalcMethod.shouldComputeSparsity();
                if(sparsityTF && not(isempty(hLvdMainGUI)))
%                     hMsgBox = msgbox('Computing sparsity.  Please wait...');
                    hMsgBox = uiprogressdlg(hLvdMainGUI, 'Message','Computing sparsity.  Please wait...', 'Title','Computing Sparsity', 'Indeterminate',true, 'Icon','info');
                else
                    hMsgBox = NaN;
                end
                
                fAtX0 = objFunToPass(x0All);
                gradCalcMethod.computeGradientSparsity(objFuncWrapper, x0All, fAtX0, obj.usesParallel());
                
                if(sparsityTF && isgraphics(hMsgBox))
                    close(hMsgBox); drawnow;
                end

            elseif(lvdOpt.gradAlgo == LvdOptimizerGradientCalculationAlgoEnum.DerivEst)
                opts = optimoptions(opts, 'SpecifyObjectiveGradient',true);
                gradCalcMethod = lvdOpt.derivEstFiniteDiffCalcMethod;
                objFunToPass = @(x) obj.objFuncWithGradient(objFuncWrapper, x, gradCalcMethod, obj.usesParallel());

            else
                error('Unknown gradient algorithm: %s', lvdOpt.gradAlgo.name);
            end
            
            %need to fix issues with variables being on bounds causing
            %fmincon to go crazy on setting the initial condition
            bool = x0All >= ubAll;
            x0All(bool) = ubAll(bool) - 10*eps;

            bool = x0All <= lbAll;
            x0All(bool) = lbAll(bool) + 10*eps;

            %create problem
            problem = createOptimProblem('fmincon', 'objective',objFunToPass, 'x0', x0All, 'lb', lbAll, 'ub', ubAll, 'nonlcon', nonlcon, 'options', opts);
            problem.lvdData = lvdOpt.lvdData; %need to get lvdData in somehow
                    
            %%% Run optimizer
            recorder = ma_OptimRecorder();
            celBodyData = lvdOpt.lvdData.celBodyData;
            
            if(callOutputFcn)
                propNames = lvdOpt.lvdData.launchVehicle.tankTypes.getFirstThreeTypesCellArr();

                out = AppDesignerGUIOutput();
                ma_ObserveOptimGUI_App(out);
                handlesObsOptimGui = out.output{1};
                appObsOptimGui = out.output{2};

                hOptimStatusLabel = handlesObsOptimGui.optimStatusLabel;
                hFinalStateOptimLabel = appObsOptimGui.finalStateOptimLabel;
                hDispAxes = handlesObsOptimGui.dispAxesPanel;
                hCancelButton = handlesObsOptimGui.cancelButton;
                optimStartTic = tic();
                
                outputFnc = @(x, optimValues, state) FminconOptimizer.getOutputFunction(x, optimValues, state, hOptimStatusLabel, hFinalStateOptimLabel, hDispAxes, hCancelButton, ...
                                                                                        objFuncWrapper, problem.lb, problem.ub, celBodyData, recorder, propNames, writeOutput, varNameStrs, lbUsAll, ubUsAll, optimStartTic);
                problem.options.OutputFcn = outputFnc;
            end
            
            [exitflag, message] = lvd_executeOptimProblem(celBodyData, writeOutput, problem, recorder, callOutputFcn);
            
            if(callOutputFcn)
                close(handlesObsOptimGui.ma_ObserveOptimGUI);
            end
        end
        
        function options = getOptions(obj)
            options = obj.options;
        end
        
        function setGradientCalculationMethod(obj, newGradCalcMethod)
            obj.gradCalcMethod = newGradCalcMethod;
        end
        
        function openOptionsDialog(obj)           
            output = AppDesignerGUIOutput({false});
            lvd_editFminconOptionsGUI_App(obj, output);
        end
        
        function tf = usesParallel(obj)
            tf = obj.options.useParallel.optionVal;
        end
        
        function numWorkers = getNumParaWorkers(obj)
            numWorkers = obj.options.getNumParaWorkers();
        end
    end
    
    methods(Access=private)
        function [f, g, stateLog] = objFuncWithGradient(~, objFun, x, gradCalcMethod, useParallel)
            [f, stateLog] = objFun(x);
            
            if(nargout >= 2)
                g = gradCalcMethod.computeGrad(objFun, x, f, useParallel);
            end
        end
    end
    
    methods(Static, Access=private)
        function stop = getOutputFunction(x, optimValues, state, hOptimStatusLabel, hFinalStateOptimLabel, hDispAxes, hCancelButton, ...
                                          objFcn, lb, ub, celBodyData, recorder, propNames, writeOutput, varLabels, lbUsAll, ubUsAll, optimStartTic)
            switch state
                case 'iter'
                    stop = get(hCancelButton,'Value');

                    recorder.iterNums(end+1) = optimValues.iteration;
                    recorder.xVals(end+1) = {x};
                    recorder.fVals(end+1) = optimValues.fval;            
                    recorder.maxCVal(end+1) = optimValues.constrviolation;
                case {'init','interrupt','done'}
                    stop = get(hCancelButton,'Value');
            end
            
            if(stop == true)
                return;
            end
            
            [~, stateLog] = objFcn(x);
            
%             finalStateLogEntry = stateLog.getFinalStateLogEntry();
%             finalStateLogEntryMA = finalStateLogEntry.getMAFormattedStateLogMatrix(true);

%             stateLogMA = stateLog.getMAFormattedStateLogMatrix(true);
            
            if(strcmpi(state,'init') || strcmpi(state,'iter'))
                try
                    FminconOptimizer.writeOptimStatus(hOptimStatusLabel, optimValues, state, writeOutput, optimStartTic);
                    
                    [stateStr, stateTooltipStr, clipboardData] = lvd_UpdateStateReadout(AbstractReferenceFrame.empty(1,0), ElementSetEnum.KeplerianElements, 'final', stateLog);
                    hFinalStateOptimLabel.Text = stateStr;
                    hFinalStateOptimLabel.Tooltip = stateTooltipStr;
                    hFinalStateOptimLabel.UserData = clipboardData;

                    FminconOptimizer.generatePlots(x, optimValues, state, hDispAxes, lb, ub, varLabels, lbUsAll, ubUsAll);
                    drawnow;
                catch ME
                    warning(ME.message);
                end
            end
        end
        
        function writeOptimStatus(hOptimStatusLabel, optimValues, state, writeOutput, timer)
            elapTime = toc(timer);

            outStr = {};
            outStr{end+1} = ['State                = ', state];
            outStr{end+1} = '                        ';
            outStr{end+1} = ['Iterations           = ', num2str(optimValues.iteration)];
            outStr{end+1} = ['Function Evals       = ', num2str(optimValues.funccount)];
            outStr{end+1} = ['Objective Value      = ', num2str(optimValues.fval)];
            outStr{end+1} = ['Constraint Violation = ', num2str(optimValues.constrviolation)];
            outStr{end+1} = ['Optimality           = ', num2str(optimValues.firstorderopt)];
            outStr{end+1} = ['Step Size            = ', num2str(optimValues.stepsize)];
            outStr{end+1} = '                       ';
            outStr{end+1} = ['Elapsed Time         = ', num2str(elapTime), ' sec'];
            
            set(hOptimStatusLabel, 'String', outStr);
            
            switch state
                case 'iter'
                    formatstr = ' %- 12.1i %- 12.0i %- 12.6g %- 12.3g %- 12.3g %- 12.3g';

                    iter = optimValues.iteration;
                    fcnt = optimValues.funccount;
                    val  = optimValues.fval;
                    feas = optimValues.constrviolation;
                    optm = optimValues.firstorderopt;
                    step = optimValues.stepsize;

                    hRow = sprintf(formatstr,iter,fcnt,val,feas,optm,step);
                    writeOutput(hRow,'append');
                case 'init'
                    hdrStr = sprintf('%- 13s%- 13s%- 13s%- 13s%- 13s%- 13s', 'Iteration','Fcn-Count','f(x)-Value', 'Feasibility', 'Optimality', 'Norm. Step');
                    writeOutput(hdrStr,'append');
            end
        end
        
        function generatePlots(x, optimValues, state, hDispAxes, lb, ub, varLabels, lbUsAll, ubUsAll)
            global GLOBAL_AppThemer %#ok<GVMIS>
            persistent fValPlotIsLog tLayout hPlot1 hPlot2 hPlot3

            if(isempty(fValPlotIsLog))
                fValPlotIsLog = true;
            end

            switch state
                case 'init'
                    if(isvalid(hDispAxes))
%                         set(hDispAxes,'Visible','on');
%                         subplot(hDispAxes);
                        tLayout = tiledlayout(hDispAxes, 3,1);
%                         axes(hDispAxes);
                    end
                    fValPlotIsLog = true;
            end

            hPlot1 = nexttile(tLayout, 1);
            if(strcmpi(state,'init'))
%                 hPlot1 = subplot(hDispAxes, 3,1,1);
                
                hPlot1.XTickLabel= [];
                hPlot1.YTickLabel= [];
                hPlot1.ZTickLabel= [];
%                 axes(hPlot1);
            end
            optimplotxKsptot(x, optimValues, state, lb, ub, varLabels, lbUsAll, ubUsAll);

            hPlot2 = nexttile(tLayout, 2);
            if(strcmpi(state,'init'))
%                 hPlot2 = subplot(3,1,2);
                
                hPlot2.XTickLabel= [];
                hPlot2.YTickLabel= [];
                hPlot2.ZTickLabel= [];
                h = hPlot2;
            else
                h = hPlot2;
%                 axes(hPlot2);
            end
            if(optimValues.fval<=0)
                fValPlotIsLog = false;
                set(h,'yscale','linear');
            end
            optimplotfvalKsptot(x, optimValues, state);
            if(fValPlotIsLog)
                set(h,'yscale','log');
            else
                set(h,'yscale','linear');
            end
            grid on;
            grid minor;

            hPlot3 = nexttile(tLayout, 3);
            if(strcmpi(state,'init'))
%                 hPlot3 = subplot(3,1,3);
                
                hPlot3.XTickLabel= [];
                hPlot3.YTickLabel= [];
                hPlot3.ZTickLabel= [];
                h = hPlot3;
            else
                h = hPlot3;
%                 axes(hPlot3);
            end
            optimplotconstrviolationKsptot(x, optimValues, state);

            if(not(isempty(h.Children)))
                hLine = h.Children(1);
                if(isa(hLine,'matlab.graphics.chart.primitive.Line'))
                    yDataLine = hLine.YData;
                    if(abs(max(yDataLine) / min(yDataLine)) >= 10 && all(yDataLine > 0))
                        set(h,'yscale','log');
                    else
                        set(h,'yscale','linear');
                    end
                else
                    set(h,'yscale','linear');
                end
            end

            grid on;
            grid minor;

            GLOBAL_AppThemer.themeWidget(hPlot1, GLOBAL_AppThemer.selTheme);
            GLOBAL_AppThemer.themeWidget(hPlot2, GLOBAL_AppThemer.selTheme);
            GLOBAL_AppThemer.themeWidget(hPlot3, GLOBAL_AppThemer.selTheme);
        end
    end
end