classdef Generic3DTrajectoryViewType < AbstractTrajectoryViewType
    %Generic3DTrajectoryViewType Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Transient)
        skyboxPostCameraPosSetListener
    end

    methods
        function obj = Generic3DTrajectoryViewType()
            
        end
        
        function [hCBodySurf, childrenHGs] = plotStateLog(obj, orbitNumToPlot, lvdData, viewProfile, handles, app)
            arguments
                obj Generic3DTrajectoryViewType
                orbitNumToPlot
                lvdData(1,1) LvdData
                viewProfile(1,1) LaunchVehicleViewProfile
                handles
                app ma_LvdMainGUI_App
            end

            %TODO: Add some usful tooltips to data plotted in here (ground objs,
            %celetial body orbits ,etc.  Turn off tool tips for the mesh spheres
            %of bodies and atmospheres.

            global GLOBAL_AppThemer %#ok<GVMIS>

%             dAxes = app.dispAxes;
            dAxes = app.dispAxes;
            hFig = app.ma_LvdMainGUI;
            celBodyData = lvdData.celBodyData;
            stateLog = lvdData.stateLog;
            
%             axes(dAxes);
%             cla(dAxes);
            % cla(dAxes,'reset');
            delete(dAxes.Children);
            dAxes.Color = viewProfile.backgroundColor.color;

            % dAxes.CameraPositionMode = "manual";
            % dAxes.CameraTargetMode = "manual";
            % dAxes.CameraViewAngleMode = "manual";
            
            % hFig.Renderer = viewProfile.renderer.renderer;
            % if(viewProfile.renderer == FigureRendererEnum.OpenGL && ~isunix())
            %     d = opengl('data');
            %     if(strcmpi(d.HardwareSupportLevel,'full'))
            %         opengl hardware;
            %     elseif(strcmpi(d.HardwareSupportLevel,'basic'))
            %         opengl hardwarebasic;
            %     end
            % end
            
            hFig.GraphicsSmoothing = 'on';
            
            if(stateLog.getNumberOfEntries() == 0)
                return;
            end
            
            viewInFrame = viewProfile.frame;
            viewCentralBody = viewInFrame.getOriginBody();
            lvdStateLogEntries = LaunchVehicleStateLogEntry.empty(1,0);
            switch viewProfile.trajEvtsViewType
                case ViewEventsTypeEnum.SoIChunk
                    entries = stateLog.getAllEntries();
%                     maStateLog = stateLog.getMAFormattedStateLogMatrix(false);

%                     chunkedStateLog = breakStateLogIntoSoIChunks(maStateLog);
                    chunkedStateLog = stateLog.breakUpStateLogBySoIChunk();
                    if(orbitNumToPlot > size(chunkedStateLog,1))
                        orbitNumToPlot = size(chunkedStateLog,1);
                        set(dAxes,'UserData',orbitNumToPlot);
                    end
                    subStateLogs = chunkedStateLog(orbitNumToPlot,:);
                    
                    bodyId = subStateLogs{1}(1,8);
                    bodyInfo = celBodyData.getBodyInfoById(bodyId);
                    evtIds = [];
                    for(i=1:length(subStateLogs))
                        subStateLog = subStateLogs{i};
                        
                        if(isempty(subStateLog))
                            continue;
                        end
                        
                        bodyId = subStateLog(1,8);
                        bodyInfo = celBodyData.getBodyInfoById(bodyId);
                        inertialFrame = bodyInfo.getBodyCenteredInertialFrame();
                        
                        elemSet = CartesianElementSet(subStateLog(:,1), subStateLog(:,2:4)', subStateLog(:,5:7)', inertialFrame);
                        elemSet = convertToFrame(elemSet, viewInFrame);

                        subStateLog(:,2:4) = [elemSet.rVect]';
                        subStateLog(:,5:7) = [elemSet.vVect]';
                        
                        evtIds = [evtIds, unique(subStateLog(:,13))']; %#ok<AGROW>
                        
                        subStateLogs{i} = subStateLog;
                    end
                    
                    evtIds = unique(evtIds);
                    for(i=1:length(entries))
                        entry = entries(i);
                        
                        if(not(isempty(entry.event.getEventNum())) && ...
                           ismember(entry.event.getEventNum(), evtIds) && ...
                           entry.centralBody == bodyInfo)
                            lvdStateLogEntries(end+1) = entry; %#ok<AGROW>
                        end
                    end

                    numTotMissionSegs = size(chunkedStateLog,1);
                
                    if(numTotMissionSegs <= 1)
                        app.decrOrbitToPlotNum.Enable = 'off';
                        app.incrOrbitToPlotNum.Enable = 'off';
                    else
                        app.decrOrbitToPlotNum.Enable = 'on';
                        app.incrOrbitToPlotNum.Enable = 'on';
                    end

                case ViewEventsTypeEnum.All
                    entries = stateLog.getAllEntries();
                    maStateLogMatrix = stateLog.getMAFormattedStateLogMatrix(false);

                    if(viewProfile.plotAllEvents == false && numel(viewProfile.eventsToPlot) > 0)
                        Lia = ismember([entries.event], viewProfile.eventsToPlot);
                        entries = entries(Lia);

                        eventNumsToPlot = getEventNum(viewProfile.eventsToPlot);
                        maStateLogMatrix = maStateLogMatrix(ismember(maStateLogMatrix(:,13), eventNumsToPlot), :);
                    end

                    numRows = size(maStateLogMatrix,1);
                    
                    cartesianEntry = convertToFrame(getCartesianElementSetRepresentation(entries, false),viewInFrame);
                    times = [cartesianEntry.time]';
                    rVect = [cartesianEntry.rVect]';
                    vVect = [cartesianEntry.vVect]';
                    bodyId = viewCentralBody.id + zeros(numRows,1);

                    ig = [entries.integrationGroup];
                    igNums = [ig.integrationGroupNum];

                    subStateLogsMat = [times, rVect, vVect, bodyId, maStateLogMatrix(:,9:13), igNums(:)];

                    subStateLogs = {};
                    for(igNum=1:max(igNums))
                        subStateLogs{igNum} = subStateLogsMat(subStateLogsMat(:,14) == igNum,:); %#ok<AGROW>
                    end
                    
                    lvdStateLogEntries = entries;
                otherwise
                    error('Unknown trajectory view type when plotting trajectory: %s', viewProfile.frame.name);
            end
                                  
            eventsList = [];
            minTime = Inf;
            maxTime = -Inf;
            for(i=1:length(subStateLogs))
                if(~isempty(subStateLogs{i}))
                    eventsList = [eventsList;unique(subStateLogs{i}(:,13))]; %#ok<AGROW>
                end
                if(i>1)
                    prevSubStateLog = subStateLogs{i-1};
                else
                    prevSubStateLog = NaN(1,size(subStateLogs{i},2));
                end

                if(isempty(prevSubStateLog))
                    prevSubStateLog = NaN(1,size(subStateLogs{i},2));
                end

                if(size(subStateLogs{i},1)>1)
                    [childrenHGs] = plotSubStateLog(subStateLogs{i}, prevSubStateLog, lvdData, dAxes);
                    
                    minTime = min([minTime, min(subStateLogs{i}(:,1))]);
                    maxTime = max([maxTime, max(subStateLogs{i}(:,1))]);
                end
            end
                       
            if(viewInFrame.typeEnum == ReferenceFrameEnum.BodyFixedRotating && ...
               viewProfile.showLongLatAnnotations)
                plotBodyFixedGrid(dAxes, viewCentralBody);
            end
            
            showSoI = viewProfile.showSoIRadius;
            
            %Show Thrust Vectors
            if(viewProfile.showThrustVectors)
                entryInc = viewProfile.thrustVectEntryIncr;
                scale = viewProfile.thrustVectScale;
                color = viewProfile.thrustVectColor.color;
                lineStyle = viewProfile.thrustVectLineType.linespec;
                
                subsetLvdStateLogEntries = lvdStateLogEntries(1:entryInc:length(lvdStateLogEntries));
                subsetLvdStateLogEntries = subsetLvdStateLogEntries(:)';
                cartesianEntries = convertToFrame(getCartesianElementSetRepresentation(subsetLvdStateLogEntries), viewInFrame);
                
                rVects = [cartesianEntries.rVect];
                tVects = [];
                
                [~, ~, ~, rotMatToInertial12] = viewInFrame.getOffsetsWrtInertialOrigin([cartesianEntries.time], cartesianEntries);
                for(i=1:length(subsetLvdStateLogEntries)) %#ok<*NO4LP>
                    entry = subsetLvdStateLogEntries(i);
                    cartesianEntry = cartesianEntries(i);       
                    
                    tVect = lvd_ThrottleTask(entry, 'thrust_vector', cartesianEntry.frame);
                    
                    if(norm(tVect) > 0)                       
                        [~, ~, ~, rotMatToInertial32] = entry.centralBody.getBodyCenteredInertialFrame().getOffsetsWrtInertialOrigin(entry.time, cartesianEntry);
                        
                        tVect = rotMatToInertial32 * rotMatToInertial12(:,:,i)' * tVect;
                    else
                        tVect = [0;0;0];
                    end
                    
                    tVects = [tVects, tVect]; %#ok<AGROW>
                end
                
                tVects = scale .* tVects;
                
                hold(dAxes,'on');
                quiver3(dAxes, rVects(1,:),rVects(2,:),rVects(3,:), tVects(1,:),tVects(2,:),tVects(3,:), 0, 'Color',color, 'LineStyle',lineStyle);
                hold(dAxes,'off');
            end

            %Show Drag vectors
            if(viewProfile.showDragVectors)
                entryInc = viewProfile.dragVectEntryIncr;
                scale = viewProfile.dragVectScale;       %km/N
                color = viewProfile.dragVectColor.color;
                lineStyle = viewProfile.dragVectLineType.linespec;

                subsetLvdStateLogEntries = lvdStateLogEntries(1:entryInc:length(lvdStateLogEntries));
                subsetLvdStateLogEntries = subsetLvdStateLogEntries(:)';
                cartesianEntries = convertToFrame(getCartesianElementSetRepresentation(subsetLvdStateLogEntries), viewInFrame);

                rVects = [cartesianEntries.rVect];
                dragVects = [];

                for(i=1:length(subsetLvdStateLogEntries)) %#ok<*NO4LP>
                    entry = subsetLvdStateLogEntries(i);      
                    srpVect = lvd_AeroTasks(entry, 'dragForceVector', viewInFrame); %kN
                    dragVects = [dragVects, srpVect]; %#ok<AGROW>
                end
                
                dragVects = scale .* dragVects;

                hold(dAxes,'on');
                quiver3(dAxes, rVects(1,:),rVects(2,:),rVects(3,:), dragVects(1,:),dragVects(2,:),dragVects(3,:), 0, 'Color',color, 'LineStyle',lineStyle);
                hold(dAxes,'off');
            end

            %Show SRP vectors
            if(viewProfile.showSrpVectors)
                entryInc = viewProfile.srpVectEntryIncr;
                scale = viewProfile.srpVectScale;       %km/N
                color = viewProfile.srpVectColor.color;
                lineStyle = viewProfile.srpVectLineType.linespec;

                subsetLvdStateLogEntries = lvdStateLogEntries(1:entryInc:length(lvdStateLogEntries));
                subsetLvdStateLogEntries = subsetLvdStateLogEntries(:)';
                cartesianEntries = convertToFrame(getCartesianElementSetRepresentation(subsetLvdStateLogEntries), viewInFrame);

                rVects = [cartesianEntries.rVect];
                srpVects = [];

                for(i=1:length(subsetLvdStateLogEntries)) %#ok<*NO4LP>
                    entry = subsetLvdStateLogEntries(i);      
                    srpVect = lvd_SrpTask(entry, 'SrpForceVector', viewInFrame); %N
                    srpVects = [srpVects, srpVect]; %#ok<AGROW>
                end
                
                srpVects = scale .* srpVects;

                hold(dAxes,'on');
                quiver3(dAxes, rVects(1,:),rVects(2,:),rVects(3,:), srpVects(1,:),srpVects(2,:),srpVects(3,:), 0, 'Color',color, 'LineStyle',lineStyle);
                hold(dAxes,'off');
            end

%             lfm = LiftForceModel();
%             rVects = NaN([3, length(lvdStateLogEntries)]);
%             forceVect = NaN([3, length(lvdStateLogEntries)]);
%             for(i=1:length(lvdStateLogEntries))
%                 stateLogEntry = lvdStateLogEntries(i);
% 
%                 bodyInfo = stateLogEntry.centralBody;
%                 ut = stateLogEntry.time;
%                 rVect = stateLogEntry.position;
%                 vVect = stateLogEntry.velocity;
%                 aero = stateLogEntry.aero;
%                 mass = stateLogEntry.getTotalVehicleMass();
%                 attState = stateLogEntry.attitude;
% 
%                 rVects(:,i) = rVect;
%                 force = lfm.getForce(ut, rVect, vVect, mass, bodyInfo, aero, [], [], [], [], [], [], [], [], [], [], attState);
%                 forceVect(:,i) = 1000*force;
%             end
% 
%             hold(dAxes,'on');
%             quiver3(dAxes, rVects(1,:),rVects(2,:),rVects(3,:), forceVect(1,:),forceVect(2,:),forceVect(3,:), 0, 'Color','c', 'LineStyle','-');
%             hold(dAxes,'off');

            if(showSoI && ~isempty(viewCentralBody.getParBodyInfo(celBodyData)))
                hold(dAxes,'on');
                
                r = getSOIRadius(viewCentralBody, viewCentralBody.getParBodyInfo(celBodyData));

                x = r*sin(0:0.01:2*pi);
                y = r*cos(0:0.01:2*pi);
                z = zeros(size(x));
                plot3(dAxes, x, y, z, 'k--','LineWidth',0.5);
                plot3(dAxes, y, z, x, 'k--','LineWidth',0.5);
                plot3(dAxes, z, x, y, 'k--','LineWidth',0.5);
                
                hold(dAxes,'off');
            end
                       
            if(viewProfile.dispXAxis || viewProfile.dispYAxis || viewProfile.dispZAxis)
                axisLength = 2*viewCentralBody.radius;
                
                hold(dAxes,'on');
                if(viewProfile.dispXAxis)
                    quiver3(dAxes, 0,0,0, axisLength,0,0, 'r', 'LineWidth',2);
                end
                
                if(viewProfile.dispYAxis)
                    quiver3(dAxes, 0,0,0, 0,axisLength,0, 'g', 'LineWidth',2);
                end
                
                if(viewProfile.dispZAxis)
                    quiver3(dAxes, 0,0,0, 0,0,axisLength, 'b', 'LineWidth',2);
                end
                hold(dAxes,'off');
            end
                                    
            %plot central body
            [hCBodySurf, hCBodySurfXForm] = ma_initOrbPlot(hFig, dAxes, viewCentralBody);
            hCBodySurf.EdgeAlpha = viewProfile.meshEdgeAlpha; 
  
            if(viewProfile.showAtmosphere && viewCentralBody.atmohgt > 0)
                hold(dAxes,'on');
                atmoRadius = viewCentralBody.radius + viewCentralBody.atmohgt;
                [X,Y,Z] = sphere(50);
                hCBodySurf = surf(dAxes, atmoRadius*X,atmoRadius*Y,atmoRadius*Z, 'BackFaceLighting','lit', 'FaceLighting','gouraud', 'FaceColor',[223 223 223]/255, 'FaceAlpha',0.2, 'EdgeLighting','gouraud', 'LineWidth',0.1, 'EdgeColor','none');
                hold(dAxes,'off');
            end
            
            eventsList = unique(eventsList);
            minEventNum = min(eventsList);
            maxEventNum = max(eventsList);
            
            if(minEventNum < maxEventNum)
                eventStr = sprintf('Events %s', getPrettyStringForIntegerArray(eventsList));
            else
                eventStr = ['Event ', num2str(minEventNum)];
            end
            
            hDispAxisTitleLabel = handles.dispAxisTitleLabel;
            titleStr = sprintf('%s Orbit -- %s\n%s', viewCentralBody.name, eventStr, viewInFrame.getNameStr());
            hDispAxisTitleLabel.String = titleStr;
            hDispAxisTitleLabel.TooltipString = sprintf('Frame: %s', viewInFrame.getNameStr());
            
            set(dAxes,'LineWidth',1);
            set(dAxes,'Box','on');
            grid(dAxes,'off'); grid(dAxes,viewProfile.gridType.gridStr);
            dAxes.GridColor = viewProfile.majorGridColor.color;
            dAxes.MinorGridColor = viewProfile.minorGridColor.color;
            dAxes.GridAlpha = viewProfile.gridTransparency;
            dAxes.XColor = viewProfile.majorGridColor.color;
            dAxes.YColor = viewProfile.majorGridColor.color;
            dAxes.ZColor = viewProfile.majorGridColor.color;

            if(viewProfile.showAxesBox)
                dAxes.Box = 'on';
                dAxes.XGrid = 'on';
                dAxes.YGrid = 'on';
                dAxes.ZGrid = 'on';
                dAxes.Visible = 'on';
            else
                dAxes.Box = 'off';
                dAxes.XGrid = 'off';
                dAxes.YGrid = 'off';
                dAxes.ZGrid = 'off';
                dAxes.Visible = 'off';
            end

            app.DisplayAxesGridLayout.BackgroundColor = viewProfile.backgroundColor.color;
            
            set(dAxes,'XTickLabel',[]);
            set(dAxes,'YTickLabel',[]);
            set(dAxes,'ZTickLabel',[]);
                                               
            vehPosVelData = LaunchVehicleViewProfile.createVehPosVelData(subStateLogs, lvdData.script.evts, viewInFrame);
            vehAttData = LaunchVehicleViewProfile.createVehAttitudeData(vehPosVelData, lvdStateLogEntries, lvdData.script.evts, viewInFrame);
            
            if(viewProfile.trajEvtsViewType ==  ViewEventsTypeEnum.All && viewProfile.plotAllEvents == false && numel(viewProfile.eventsToPlot)>0)
                eventsToPlot = viewProfile.eventsToPlot;
            else
                eventsToPlot = lvdData.script.evts;
            end

            hold(dAxes,'on');
            viewProfile.createBodyMarkerData(dAxes, subStateLogs, viewInFrame, showSoI, viewProfile.meshEdgeAlpha, eventsToPlot);           
            viewProfile.createTrajectoryMarkerData(subStateLogs, eventsToPlot);
            viewProfile.createBodyAxesData(vehPosVelData, vehAttData); %lvdStateLogEntries, lvdData.script.evts, viewInFrame
            viewProfile.createSunLightSrc(dAxes, viewInFrame);
            viewProfile.createGroundObjMarkerData(dAxes, lvdStateLogEntries, vehPosVelData, eventsToPlot, viewInFrame, celBodyData);
            viewProfile.createCentralBodyData(viewCentralBody, hCBodySurfXForm, viewInFrame);
            viewProfile.createPointData(viewInFrame, subStateLogs, eventsToPlot);           
            viewProfile.createVectorData(viewInFrame, subStateLogs, eventsToPlot);
            viewProfile.createRefFrameData(viewInFrame, subStateLogs, eventsToPlot);
            viewProfile.createAngleData(viewInFrame, subStateLogs, eventsToPlot);
            viewProfile.createPlaneData(viewInFrame, subStateLogs, eventsToPlot);           
            viewProfile.createSensorData(lvdStateLogEntries, vehPosVelData, vehAttData, viewInFrame);
            viewProfile.createSensorTargetData(viewInFrame);
            
            viewProfile.configureTimeSlider(minTime, maxTime, subStateLogs, handles, app);

            switch viewProfile.projType
                case ViewProjectionTypeEnum.Orthographic
                    camproj(dAxes, 'orthographic');
    
                case ViewProjectionTypeEnum.Perspective
                    camproj(dAxes, 'perspective');

                otherwise
                    error('Unknown projection type: %s', viewProfile.projType.name);

            end

            % Experimental skybox
            if(viewProfile.useSkybox)
                hold(dAxes, 'on');
                grid(dAxes,'off');
                axis(dAxes,'equal');
                dAxes.XTick = [];
                dAxes.YTick = [];
                dAxes.ZTick = [];
                dAxes.Box = "off";
                dAxes.XColor = "none";
                dAxes.YColor = "none";
                dAxes.ZColor = "none";
                camproj(dAxes, 'perspective'); %THIS IS REQUIRED TO MAKE A "SKYBOX" WORK!!!
                dAxes.Clipping = "off";
                dAxes.ClippingStyle = "3dbox";

                delete(obj.skyboxPostCameraPosSetListener);

                lFh = @(src,evt) updateSkyboxPos(src,evt, dAxes, lvdData);
                lFh([],[]);

                obj.skyboxPostCameraPosSetListener = addlistener(dAxes,'CameraPosition','PostSet', lFh);
            else
                delete(obj.skyboxPostCameraPosSetListener);
                delete(viewProfile.skyBoxSurfHandle);

                dAxes.XTickMode = 'auto';
                dAxes.YTickMode = 'auto';
                dAxes.ZTickMode = 'auto';
            end

            if(not(viewProfile.updateViewAxesLimits))                
                camPos = viewProfile.viewCameraPosition;
                camTgt = viewProfile.viewCameraTarget;
                camUpVec = viewProfile.viewCameraUpVector;
                camVA = viewProfile.viewCameraViewAngle;
                
                if(not(any(isnan(camPos))))
                    dAxes.CameraPosition = camPos;
                end
                
                if(not(any(isnan(camTgt))))
                    dAxes.CameraTarget = camTgt;
                end
                
                if(not(any(isnan(camUpVec))))
                    dAxes.CameraUpVector = camUpVec;
                end
                
                if(not(any(isnan(camVA))))
                    dAxes.CameraViewAngle = camVA;
                end           
            else
                cameratoolbar(hFig, 'ResetCamera');
                view(dAxes, 3);

                viewProfile.viewCameraPosition = dAxes.CameraPosition;
                viewProfile.viewCameraTarget = dAxes.CameraTarget;
                viewProfile.viewCameraUpVector = dAxes.CameraUpVector;
                viewProfile.viewCameraViewAngle = dAxes.CameraViewAngle;
            end

            %Retheme app to apply axes styling
            if(viewProfile.useThemeForAxes)
                GLOBAL_AppThemer.themeWidget(dAxes, GLOBAL_AppThemer.selTheme);
                GLOBAL_AppThemer.themeWidget(app.DisplayAxesGridLayout, GLOBAL_AppThemer.selTheme);
            end
        end
    end
end

function [childrenHGs] = plotSubStateLog(subStateLog, prevSubStateLog, lvdData, dAxes)    
    if(isempty(subStateLog))
        childrenHGs = [];
        return;
    end
    
%     bodyID = subStateLog(1,8);
%     bodyInfo = getBodyInfoByNumber(bodyID, celBodyData);

    eventNum = subStateLog(1,13);
    event = lvdData.script.getEventForInd(eventNum);
    if(isempty(event))
        childrenHGs = [];
        return;
    end
    
    plotLineColor = event.colorLineSpec.color.color;
    plotLineStyle = event.colorLineSpec.lineSpec.linespec;
    plotLineWidth = event.colorLineSpec.lineWidth;
    plotMarkerType = event.colorLineSpec.markerSpec.shape;
    plotMarkerSize = event.colorLineSpec.markerSize;
    plotMethodEnum = event.plotMethod;

    hold(dAxes,'on');
    
    switch plotMethodEnum
        case EventPlottingMethodEnum.PlotContinuous
            t = [prevSubStateLog(end,1);subStateLog(1:end,1)];
            x = [prevSubStateLog(end,2);subStateLog(1:end,2)];
            y = [prevSubStateLog(end,3);subStateLog(1:end,3)];
            z = [prevSubStateLog(end,4);subStateLog(1:end,4)];

            [~,I] = sort(t);
            x = x(I);
            y = y(I);
            z = z(I);

        case EventPlottingMethodEnum.SkipFirstState
            t = subStateLog(2:end,1);
            x = subStateLog(2:end,2);
            y = subStateLog(2:end,3);
            z = subStateLog(2:end,4);
        case EventPlottingMethodEnum.DoNotPlot
            t = [];
            x = [];
            y = [];
            z = [];
        otherwise
            error('Unknown event plotting method enum: %s', plotMethodEnum.name);
    end

    l = plot3(dAxes, x, y, z, 'Color', plotLineColor, 'LineStyle', plotLineStyle, 'LineWidth',plotLineWidth, 'Marker',plotMarkerType, 'MarkerSize',plotMarkerSize, 'MarkerEdgeColor','none', 'MarkerFaceColor',plotLineColor);   
    
    if(~isempty(t))
        [year, day, hour, minute, sec] = convertSec2YearDayHrMnSec(t);
        
        epochStr = string.empty(1,0);
        for(i=1:length(t))
            epochStr(i) = string(formDateStr(year(i), day(i), hour(i), minute(i), sec(i))); %#ok<AGROW>
        end
        
        l.DataTipTemplate.DataTipRows = [dataTipTextRow("Epoch", epochStr);
                                         dataTipTextRow("X Pos [km]", x);
                                         dataTipTextRow("Y Pos [km]", y);
                                         dataTipTextRow("Z Pos [km]", z);
                                         dataTipTextRow("Event", repmat(string(event.getListboxStr()), size(x)))];
    end
    
    
    childrenHGs = cell(0,4);
end

function plotBodyFixedGrid(dAxes, bodyInfo)
    r = 1.2*bodyInfo.radius;
    rTxt = 1.3*bodyInfo.radius;

    %draw longitude circle and text
    th = linspace(0, 2*pi, 100);
    xunit = r * cos(th);
    yunit = r * sin(th);
    patch(dAxes, 'XData',xunit,'YData',yunit, 'FaceColor', 'k', 'FaceAlpha',0.15);

    th = linspace(0,2*pi - (1/12)*2*pi, 12);
    xunit = r * cos(th);
    yunit = r * sin(th);

    xToPlot = [];
    yToPlot = [];
    for(i=1:length(th))
        xToPlot = [xToPlot, 0, xunit(i), NaN]; %#ok<AGROW>
        yToPlot = [yToPlot, 0, yunit(i), NaN]; %#ok<AGROW>
    end

    plot(dAxes, xToPlot, yToPlot, 'k');

    xunitTxt = rTxt * cos(th);
    yunitTxt = rTxt * sin(th);

    for(i=1:length(xunitTxt))
        text(dAxes, xunitTxt(i),yunitTxt(i),sprintf('%.0f%s', rad2deg(th(i)), char(176)));
    end

    %draw latitude circle and text
    th = linspace(-pi/2, pi/2, 100);
    xunit = r * cos(th);
    yunit = zeros(size(th));
    zunit = r * sin(th);
    patch(dAxes, 'XData',xunit,'YData',yunit,'ZData',zunit, 'FaceColor', 'k', 'FaceAlpha',0.15);

    th = rad2deg(linspace(-pi/2, pi/2, 7));
    xunit = r * cosd(th);
    yunit = zeros(size(th));
    zunit = r * sind(th);

    xToPlot = [];
    yToPlot = [];
    zToPlot = [];
    for(i=1:length(th))
        xToPlot = [xToPlot, 0, xunit(i), NaN]; %#ok<AGROW>
        yToPlot = [yToPlot, 0, yunit(i), NaN]; %#ok<AGROW>
        zToPlot = [zToPlot, 0, zunit(i), NaN]; %#ok<AGROW>
    end

    plot3(dAxes, xToPlot, yToPlot, zToPlot, 'k');

    xunitTxt = rTxt * cosd(th);
    yunitTxt = zeros(size(th));
    zunitTxt = rTxt * sind(th);

    for(i=1:length(xunitTxt))
        text(dAxes, xunitTxt(i),yunitTxt(i),zunitTxt(i), sprintf('%.0f%s', th(i), char(176)));
    end
end

function updateSkyboxPos(src,evt, hAx, lvdData)
    arguments
        src
        evt
        hAx(1,1) matlab.graphics.axis.Axes
        lvdData(1,1) LvdData
    end

    viewProfile = lvdData.viewSettings.selViewProfile;

    cameraPos = campos(hAx);
    cameraTgt = camtarget(hAx);
    cameraVa = camva(hAx);

    if(viewProfile.useSkybox)
        if(isempty(viewProfile.skyboxOrigin) || isempty(viewProfile.skyboxRadius) || isempty(viewProfile.skyBoxSurfHandle) || ~isvalid(viewProfile.skyBoxSurfHandle) || norm(cameraPos - viewProfile.skyboxOrigin) > 0.5*viewProfile.skyboxRadius) %only update skybox sphere if we get too close to the edge
            if(not(isempty(viewProfile.skyBoxSurfHandle)) && isvalid(viewProfile.skyBoxSurfHandle))
                viewProfile.skyBoxSurfHandle.Visible = 'off'; %This makes sure that the axes bounds are set without including the skybox.  Just turn the skybox back on later. 
            end
        
            xBndMaxDistToCamPos = max(abs(cameraPos(1) - xlim(hAx)));
            yBndMaxDistToCamPos = max(abs(cameraPos(2) - ylim(hAx)));
            zBndMaxDistToCamPos = max(abs(cameraPos(3) - zlim(hAx)));
            
            skyboxSize = viewProfile.skyboxRadiusMultiplier * max([xBndMaxDistToCamPos, yBndMaxDistToCamPos, zBndMaxDistToCamPos]);
            
            viewProfile.skyboxOrigin = cameraPos;
            viewProfile.skyboxRadius = skyboxSize;

            [X,Y,Z] = sphere(30);
            if(isempty(viewProfile.skyBoxSurfHandle) || not(isvalid(viewProfile.skyBoxSurfHandle)))
                if(isempty(viewProfile.skyBoxImageI))
                    I = imread(viewProfile.skyBoxImgFileName);
                    I = flipud(I);
                    % I = imresize(I, 1, "bilinear","Antialiasing",true);

                    viewProfile.skyBoxImageI = I;
                else
                    I = viewProfile.skyBoxImageI;
                end
        
                hold(hAx,'on');
                viewProfile.skyBoxSurfHandle = surf(hAx, skyboxSize*X+cameraPos(1),skyboxSize*Y+cameraPos(2),skyboxSize*Z+cameraPos(3), "EdgeColor","none", "FaceColor","texturemap", 'CData',I, 'FaceLighting','none');
            else
                viewProfile.skyBoxSurfHandle.XData = skyboxSize*X+cameraPos(1);
                viewProfile.skyBoxSurfHandle.YData = skyboxSize*Y+cameraPos(2);
                viewProfile.skyBoxSurfHandle.ZData = skyboxSize*Z+cameraPos(3);
                viewProfile.skyBoxSurfHandle.Visible = 'on';
            end
    
            camtarget(hAx, cameraTgt);
            camva(hAx, cameraVa);
            campos(hAx, cameraPos);
        end
    else
        delete(viewProfile.skyBoxSurfHandle);
    end
end