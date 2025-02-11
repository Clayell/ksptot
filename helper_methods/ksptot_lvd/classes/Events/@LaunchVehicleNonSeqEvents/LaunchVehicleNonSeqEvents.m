classdef LaunchVehicleNonSeqEvents < matlab.mixin.SetGet & matlab.mixin.Copyable
    %LaunchVehicleNoneSeqEvents Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        nonSeqEvts LaunchVehicleNonSeqEvent
        
        lvdData LvdData
    end
    
    properties(Dependent)
        evts LaunchVehicleEvent
    end
    
    methods
        function obj = LaunchVehicleNonSeqEvents(lvdData)
            obj.lvdData = lvdData;
            obj.nonSeqEvts = LaunchVehicleNonSeqEvent.empty(1,0);
        end
        
        function values = get.evts(obj)
            values = LaunchVehicleEvent.empty(1,0);
            
            for(i=1:length(obj.nonSeqEvts))
                values(end+1) = obj.nonSeqEvts(i).evt; %#ok<AGROW>
            end
        end
        
        function activeNonSeqEvts = getNonSeqEventsForScriptEvent(obj, evt)
            activeNonSeqEvts = LaunchVehicleNonSeqEvent.empty(1,0);
            evtNum = evt.getEventNum();
            
            for(i=1:length(obj.nonSeqEvts))
                nonSeqEvt = obj.nonSeqEvts(i);
                
                if(nonSeqEvt.numExecsRemaining > 0)
                    if(not(isempty(nonSeqEvt.lwrBndEvt)))
                        lwrBndEvtNum = nonSeqEvt.lwrBndEvt.getEventNum();
                    else
                        lwrBndEvtNum = 0;
                    end

                    if(not(isempty(nonSeqEvt.uprBndEvt)))
                        uprBndEvtNum = nonSeqEvt.uprBndEvt.getEventNum();
                    else
                        uprBndEvtNum = Inf;
                    end

                    if(evtNum >= lwrBndEvtNum && evtNum <= uprBndEvtNum)
                        activeNonSeqEvts(end+1) = nonSeqEvt; %#ok<AGROW>
                    end
                end
            end
        end
        
        function addEvent(obj, newEvt)
            obj.nonSeqEvts(end+1) = newEvt;
        end
        
        function addEventAtInd(obj, newEvt, ind)
            if(not(isempty(obj.nonSeqEvts)))
                if(ind == length(obj.nonSeqEvts))
                    obj.nonSeqEvts(end+1) = newEvt;
                else
                    obj.nonSeqEvts = [obj.nonSeqEvts(1:ind), newEvt, obj.nonSeqEvts(ind+1:end)];
                end
            else
                obj.nonSeqEvts(end+1) = newEvt;
            end
        end
        
        function removeEvent(obj, nonSeqEvt)
            arguments
                obj(1,1) LaunchVehicleNonSeqEvents
                nonSeqEvt(1,1) LaunchVehicleNonSeqEvent
            end

            evt = nonSeqEvt.evt;

            termCondOptVar = evt.termCond.getExistingOptVar();
            if(not(isempty(termCondOptVar)))
                obj.lvdData.optimizer.vars.removeVariable(termCondOptVar);
            end
            
            actions = evt.actions;
            for(i=1:length(actions)) %#ok<*NO4LP> 
                evt.removeAction(actions(i));
            end

            obj.nonSeqEvts(obj.nonSeqEvts == nonSeqEvt) = [];
        end
        
        function removeEventFromIndex(obj, ind)
            if(ind >= 1 && ind <= length(obj.nonSeqEvts))
                obj.removeEvent(obj.nonSeqEvts(ind));
            end
        end
        
        function evtNum = getNumOfEvent(obj, evt)
            evtNum = [];
            
            if(not(isempty(evt)))
                evtNum = find(obj.nonSeqEvts == evt);
            end
        end
        
        function evt = getEventForInd(obj, ind)
            evt = LaunchVehicleNonSeqEvent.empty(1,0);
            
            if(ind >= 1 && ind <= length(obj.nonSeqEvts))
                evt = obj.nonSeqEvts(ind);
            end
        end
        
        function numEvents = getTotalNumOfEvents(obj)
            numEvents = length(obj.nonSeqEvts);
        end
        
        function [listboxStr, events] = getListboxStr(obj)
            listboxStr = cell(length(obj.nonSeqEvts),1);
            
            for(i=1:length(obj.nonSeqEvts))
                listboxStr{i} = obj.nonSeqEvts(i).getListboxStr();
            end
            
            events = obj.nonSeqEvts;
        end
        
        function resetAllNumExecsRemaining(obj)
            for(i=1:length(obj.nonSeqEvts))
                obj.nonSeqEvts(i).resetNumExecsRemaining();
            end
        end
        
        function tf = usesStage(obj, stage)
            tf = false;
            
            for(i=1:length(obj.evts))
                tf = tf || obj.evts(i).usesStage(stage);
            end
        end
        
        function tf = usesEngine(obj, engine)
            tf = false;
            
            for(i=1:length(obj.evts))
                tf = tf || obj.evts(i).usesEngine(engine);
            end
        end
        
        function tf = usesTank(obj, tank)
            tf = false;
            
            for(i=1:length(obj.evts))
                tf = tf || obj.evts(i).usesTank(tank);
            end
        end
        
        function tf = usesEngineToTankConn(obj, engineToTank)
            tf = false;
            
            for(i=1:length(obj.evts))
                tf = tf || obj.evts(i).usesEngineToTankConn(engineToTank);
            end
        end

        function tf = usesStopwatch(obj, stopwatch)
            tf = false;
            
            for(i=1:length(obj.evts))
                tf = tf || obj.evts(i).usesStopwatch(stopwatch);
            end
        end
        
        function tf = usesExtremum(obj, extremum)
            tf = false;
            
            for(i=1:length(obj.evts))
                tf = tf || obj.evts(i).usesExtremum(extremum);
            end
        end
               
        function tf = usesCalculusCalc(obj, calculusCalc)
            tf = false;
            
            for(i=1:length(obj.evts))
                tf = tf || obj.evts(i).usesExtremum(calculusCalc);
            end
        end
        
        function tf = usesPwrSink(obj, powerSink)
            tf = false;
            
            for(i=1:length(obj.evts))
                tf = tf || obj.evts(i).usesPwrSink(powerSink);
            end
        end
        
        function tf = usesPwrSrc(obj, powerSrc)
            tf = false;
            
            for(i=1:length(obj.evts))
                tf = tf || obj.evts(i).usesPwrSrc(powerSrc);
            end
        end
        
        function tf = usesPwrStorage(obj, powerStorage)
            tf = false;
            
            for(i=1:length(obj.evts))
                tf = tf || obj.evts(i).usesPwrStorage(powerStorage);
            end
        end
        
        function tf = usesSensor(obj, sensor)
            tf = false;
            
            for(i=1:length(obj.evts))
                tf = tf || obj.evts(i).usesSensor(sensor);
            end
        end
        
        function tf = usesTankToTankConn(obj, tankToTank)
            tf = false;
            
            for(i=1:length(obj.evts))
                tf = tf || obj.evts(i).usesTankToTankConn(tankToTank);
            end
        end

        function tf = usesPluginVariable(obj, pluginVar)
            arguments
                obj(1,1) 
                pluginVar(1,1) LvdPluginOptimVarWrapper
            end

            tf = false;
            for(i=1:length(obj.evts))
                tf = tf || obj.evts(i).usesPluginVariable(pluginVar);
            end
        end
    end
    
	methods(Access = protected)
        function cpObj = copyElement(obj)
            cpObj = copyElement@matlab.mixin.Copyable(obj); 

            for(i=1:length(obj.nonSeqEvts))
                cpObj.nonSeqEvts(i) = obj.nonSeqEvts(i).copy();
            end
        end
	end
end