function varargout = lvd_EditActionSetKinematicStateGUI(varargin)
% LVD_EDITACTIONSETKINEMATICSTATEGUI MATLAB code for lvd_EditActionSetKinematicStateGUI.fig
%      LVD_EDITACTIONSETKINEMATICSTATEGUI, by itself, creates a new LVD_EDITACTIONSETKINEMATICSTATEGUI or raises the existing
%      singleton*.
%
%      H = LVD_EDITACTIONSETKINEMATICSTATEGUI returns the handle to a new LVD_EDITACTIONSETKINEMATICSTATEGUI or the handle to
%      the existing singleton*.
%
%      LVD_EDITACTIONSETKINEMATICSTATEGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LVD_EDITACTIONSETKINEMATICSTATEGUI.M with the given input arguments.
%
%      LVD_EDITACTIONSETKINEMATICSTATEGUI('Property','Value',...) creates a new LVD_EDITACTIONSETKINEMATICSTATEGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lvd_EditActionSetKinematicStateGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lvd_EditActionSetKinematicStateGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lvd_EditActionSetKinematicStateGUI

% Last Modified by GUIDE v2.5 10-Jan-2020 17:25:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lvd_EditActionSetKinematicStateGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @lvd_EditActionSetKinematicStateGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before lvd_EditActionSetKinematicStateGUI is made visible.
function lvd_EditActionSetKinematicStateGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to lvd_EditActionSetKinematicStateGUI (see VARARGIN)

% Choose default command line output for lvd_EditActionSetKinematicStateGUI
    handles.output = hObject;
    
    action = varargin{1};
    setappdata(hObject, 'action', action);
    
    lvdData = varargin{2};
    setappdata(hObject, 'lvdData', lvdData);
    
    action.stateLog = lvdData.stateLog;
    
    populateGUI(handles, action, lvdData);

    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes lvd_EditActionSetKinematicStateGUI wait for user response (see UIRESUME)
    uiwait(handles.lvd_EditActionSetKinematicStateGUI);

    
function populateGUI(handles, action, lvdData)
    orbitModel = action.orbitModel;
    
    if(isnan(orbitModel.time))
        orbitModel.time = 0;
    end
    
    if(any(isnan(orbitModel.getElementVector())))
        bodyInfo = lvdData.getDefaultInitialBodyInfo(lvdData.celBodyData);
        newFrame = bodyInfo.getBodyFixedFrame();
        
        orbitModel = GeographicElementSet(orbitModel.time, 0, 0, 0, 0, 0, 0, newFrame);
    end
    
    if(isempty(orbitModel.frame))
        bodyInfo = lvdData.getDefaultInitialBodyInfo(lvdData.celBodyData);
        newFrame = bodyInfo.getBodyCenteredInertialFrame();
        
        orbitModel.frame = newFrame;
    end
    
%     frame = orbitModel.frame;
    setappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet',orbitModel);
    
%     bodyInfo = frame.getOriginBody();
%     populateBodiesCombo(lvdData.celBodyData, handles.centralBodyCombo, false);
%     value = findValueFromComboBox(bodyInfo.name, handles.centralBodyCombo);
% 	handles.centralBodyCombo.Value = value;
    
    handles.refFrameTypeCombo.String = ReferenceFrameEnum.getListBoxStr();
    handles.refFrameTypeCombo.Value = ReferenceFrameEnum.getIndForName(orbitModel.frame.typeEnum.name);
    handles.setFrameOptionsButton.TooltipString = sprintf('Current Frame: %s', orbitModel.frame.getNameStr()); 
    
    handles.elementSetCombo.String = ElementSetEnum.getListBoxStr();
    [value, elemSetEnum] = ElementSetEnum.getIndForName(orbitModel.typeEnum.name);
    handles.elementSetCombo.Value = value;
    elementSetCombo_Callback(handles.elementSetCombo, [], handles);
    
    evtListStr = lvdData.script.getListboxStr();
    thisActionEvtNum = action.event.getEventNum();
    if(not(isempty(thisActionEvtNum)))
        if(thisActionEvtNum > 1)
            finalEvtNumToShow = thisActionEvtNum-1;
        else
            finalEvtNumToShow = thisActionEvtNum;
        end
        evtListStr = evtListStr(1:finalEvtNumToShow);
    end
    
    %inherit time
    switch action.inheritTimeFrom
        case InheritStateEnum.InheritFromLastState
            handles.inheritTimeFromPrevStateRadioBtn.Value = 1;
            
        case InheritStateEnum.InheritFromSpecifiedEvent
            handles.inheritTimeFromSpecEvtRadioBtn.Value = 1;
            
        otherwise
            error('Unknown inheritance type (time): %s', class(action.inheritTimeFrom));
    end
      
    handles.inheritTimeSpecEvtCombo.String = evtListStr;
    if(not(isempty(action.inheritTimeFromEvent)))
        evtNum = action.inheritTimeFromEvent.getEventNum();
        if(evtNum > length(evtListStr))
            handles.inheritTimeSpecEvtCombo.Value = 1;
        else
            handles.inheritTimeSpecEvtCombo.Value = evtNum;
        end
    end
    
    inheritTimeButtonGroup_SelectionChangedFcn(handles.inheritTimeButtonGroup.SelectedObject,[],handles);
    
    %inherit pos/vel state
    switch action.inheritPosVelFrom
        case InheritStateEnum.InheritFromLastState
            handles.inheritStateFromPrevStateRadioBtn.Value = 1;
            
        case InheritStateEnum.InheritFromSpecifiedEvent
            handles.inheritStateFromSpecEvtRadioBtn.Value = 1;
            
        otherwise
            error('Unknown inheritance type (state): %s', class(action.inheritPosVelFrom));
    end
    
    handles.inheritStateSpecEvtCombo.String = evtListStr;
    if(not(isempty(action.inheritPosVelFromEvent)))
        evtNum = action.inheritPosVelFromEvent.getEventNum();
        if(evtNum > length(evtListStr))
            handles.inheritStateSpecEvtCombo.Value = 1;
        else
            handles.inheritStateSpecEvtCombo.Value = evtNum;
        end
    end
    
    inheritStateButtonGroup_SelectionChangedFcn(handles.inheritStateButtonGroup.SelectedObject,[],handles);
    
    %inherit stage states
    switch action.inheritStageStatesFrom
        case InheritStateEnum.InheritFromLastState
            handles.inheritStageStatesFromPrevStateRadioBtn.Value = 1;
            
        case InheritStateEnum.InheritFromSpecifiedEvent
            handles.inheritStageStatesFromSpecEvtRadioBtn.Value = 1;
            
        otherwise
            error('Unknown inheritance type (stage states): %s', class(action.inheritStageStatesFrom));
    end
    
    handles.inheritStageStatesSpecEvtCombo.String = evtListStr;
    if(not(isempty(action.inheritStageStatesFromEvent)))
        evtNum = action.inheritStageStatesFromEvent.getEventNum();
        if(evtNum > length(evtListStr))
            handles.inheritStageStatesSpecEvtCombo.Value = 1;
        else
            handles.inheritStageStatesSpecEvtCombo.Value = evtNum;
        end
    end
    
    inheritStageStatesButtonGroup_SelectionChangedFcn(handles.inheritStageStatesButtonGroup.SelectedObject, [], handles);
    
    %inherit other state elements
    switch action.inheritStateElemsFrom
        case InheritStateEnum.InheritFromLastState
            handles.inheritOtherStateElementsFromPrevStateRadioBtn.Value = 1;
            
        case InheritStateEnum.InheritFromSpecifiedEvent
            handles.inheritOtherStateElementsFromSpecEvtRadioBtn.Value = 1;
            
        otherwise
            error('Unknown inheritance type (other state elements): %s', class(action.inheritStateElemsFrom));
    end
    
    handles.inheritOtherStateElementsEvtCombo.String = evtListStr;
    if(not(isempty(action.inheritStateElemsFromEvent)))
        evtNum = action.inheritStateElemsFromEvent.getEventNum();
        if(evtNum > length(evtListStr))
            handles.inheritOtherStateElementsEvtCombo.Value = 1;
        else
            handles.inheritOtherStateElementsEvtCombo.Value = evtNum;
        end
    end
    
    inheritOtherStateElementsButtonGroup_SelectionChangedFcn(handles.inheritOtherStateElementsButtonGroup.SelectedObject, [], handles);
    
    %populate pos/vel states stuff
    if(isempty(orbitModel.time))
        orbitModel.time = 0;
    end
    handles.utText.String = fullAccNum2Str(orbitModel.time);
    
    elemVector = orbitModel.getElementVector();
    handles.orbit1Text.String = fullAccNum2Str(elemVector(1));
    handles.orbit2Text.String = fullAccNum2Str(elemVector(2));
    handles.orbit3Text.String = fullAccNum2Str(elemVector(3));
    handles.orbit4Text.String = fullAccNum2Str(elemVector(4));
    handles.orbit5Text.String = fullAccNum2Str(elemVector(5));
    handles.orbit6Text.String = fullAccNum2Str(elemVector(6));
    
    handles.inheritTimeCheckbox.Value = double(action.inheritTime);
    handles.inheritStateCheckbox.Value = double(action.inheritPosVel);
    
    optVar = action.optVar;
	if(isempty(optVar))
        optVar = SetKinematicStateActionVariable(action);
	end
    useTf = optVar.getUseTfForVariable();  
    
    handles.optUtCheckbox.Value = double(useTf(1));
    handles.optOrbit1Checkbox.Value = double(useTf(2));
    handles.optOrbit2Checkbox.Value = double(useTf(3));
    handles.optOrbit3Checkbox.Value = double(useTf(4));
    handles.optOrbit4Checkbox.Value = double(useTf(5));
    handles.optOrbit5Checkbox.Value = double(useTf(6));
    handles.optOrbit6Checkbox.Value = double(useTf(7));
    
    optVar.setUseTfForVariable(true(size(useTf)));
    [lb, ub] = optVar.getBndsForVariable();
    optVar.setUseTfForVariable(useTf);
    
    switch elemSetEnum
        case ElementSetEnum.CartesianElements
            %nothing needed

        case ElementSetEnum.KeplerianElements
            lb = [lb(1) lb(2) lb(3) rad2deg(lb(4)) rad2deg(lb(5)) rad2deg(lb(6)) rad2deg(lb(7))];
            ub = [ub(1) ub(2) ub(3) rad2deg(ub(4)) rad2deg(ub(5)) rad2deg(ub(6)) rad2deg(ub(7))];

        case ElementSetEnum.GeographicElements
            lb = [lb(1) rad2deg(lb(2)) rad2deg(lb(3)) lb(4) rad2deg(lb(5)) rad2deg(lb(6)) lb(7)];
            ub = [lb(1) rad2deg(ub(2)) rad2deg(ub(3)) ub(4) rad2deg(ub(5)) rad2deg(ub(6)) ub(7)];
            
        case ElementSetEnum.UniversalElements
            lb = [lb(1) lb(2) lb(3) rad2deg(lb(4)) rad2deg(lb(5)) rad2deg(lb(6)) lb(7)];
            ub = [ub(1) ub(2) ub(3) rad2deg(ub(4)) rad2deg(ub(5)) rad2deg(ub(6)) ub(7)];

        otherwise
            error('Unknown element set type: %s', class(elemSetEnum));
    end

    handles.utLbText.String     = fullAccNum2Str(lb(1));
    handles.orbit1LbText.String = fullAccNum2Str(lb(2));
    handles.orbit2LbText.String = fullAccNum2Str(lb(3));
    handles.orbit3LbText.String = fullAccNum2Str(lb(4));
    handles.orbit4LbText.String = fullAccNum2Str(lb(5));
    handles.orbit5LbText.String = fullAccNum2Str(lb(6));
    handles.orbit6LbText.String = fullAccNum2Str(lb(7));
    
    handles.utUbText.String     = fullAccNum2Str(ub(1));
    handles.orbit1UbText.String = fullAccNum2Str(ub(2));
    handles.orbit2UbText.String = fullAccNum2Str(ub(3));
    handles.orbit3UbText.String = fullAccNum2Str(ub(4));
    handles.orbit4UbText.String = fullAccNum2Str(ub(5));
    handles.orbit5UbText.String = fullAccNum2Str(ub(6));
    handles.orbit6UbText.String = fullAccNum2Str(ub(7));
    
    inheritTimeCheckbox_Callback(handles.inheritTimeCheckbox, [], handles);  
    inheritStateCheckbox_Callback(handles.inheritStateCheckbox, [], handles);
    optUtCheckbox_Callback(handles.optUtCheckbox, [], handles);
    optOrbit1Checkbox_Callback(handles.optOrbit1Checkbox, [], handles);
    optOrbit2Checkbox_Callback(handles.optOrbit2Checkbox, [], handles);
    optOrbit3Checkbox_Callback(handles.optOrbit3Checkbox, [], handles);
    optOrbit4Checkbox_Callback(handles.optOrbit4Checkbox, [], handles);
    optOrbit5Checkbox_Callback(handles.optOrbit5Checkbox, [], handles);
    optOrbit6Checkbox_Callback(handles.optOrbit6Checkbox, [], handles);

% --- Outputs from this function are returned to the command line.
function varargout = lvd_EditActionSetKinematicStateGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    if(isempty(handles))
        varargout{1} = false;
    else  
        lvdData = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'lvdData');
        action = getappdata(handles.lvd_EditActionSetKinematicStateGUI, 'action');
        
        action.stateLog = lvdData.stateLog;
        
        contents = cellstr(get(handles.elementSetCombo,'String'));
        selElemSet = contents{get(handles.elementSetCombo,'Value')};
        elemSetEnum = ElementSetEnum.getEnumForListboxStr(selElemSet);
        
        time = str2double(handles.utText.String);
        
        orbit1Elem = str2double(handles.orbit1Text.String);
        orbit2Elem = str2double(handles.orbit2Text.String);
        orbit3Elem = str2double(handles.orbit3Text.String);
        orbit4Elem = str2double(handles.orbit4Text.String);
        orbit5Elem = str2double(handles.orbit5Text.String);
        orbit6Elem = str2double(handles.orbit6Text.String);
        
        if(isempty(orbit1Elem))
            orbit1Elem = 0.1;
        end
        
        if(isempty(orbit2Elem))
            orbit2Elem = 0.1;
        end
        
        if(isempty(orbit3Elem))
            orbit3Elem = 0.1;
        end
        
        if(isempty(orbit4Elem))
            orbit4Elem = 0.1;
        end
        
        if(isempty(orbit5Elem))
            orbit5Elem = 0.1;
        end
        
        if(isempty(orbit6Elem))
            orbit6Elem = 0.1;
        end

        curElemSet = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet');
        frame = curElemSet.frame;
                
        switch elemSetEnum
            case ElementSetEnum.CartesianElements
                orbitModel = CartesianElementSet(time, [orbit1Elem; orbit2Elem; orbit3Elem], [orbit4Elem; orbit5Elem; orbit6Elem], frame);
                
            case ElementSetEnum.KeplerianElements
                orbitModel = KeplerianElementSet(time, orbit1Elem, orbit2Elem, deg2rad(orbit3Elem), deg2rad(orbit4Elem), deg2rad(orbit5Elem), deg2rad(orbit6Elem), frame);
                
            case ElementSetEnum.GeographicElements
                orbitModel = GeographicElementSet(time, deg2rad(orbit1Elem), deg2rad(orbit2Elem), orbit3Elem, deg2rad(orbit4Elem), deg2rad(orbit5Elem), orbit6Elem, frame);
                
            case ElementSetEnum.UniversalElements
                orbitModel = UniversalElementSet(time, orbit1Elem, orbit2Elem, deg2rad(orbit3Elem), deg2rad(orbit4Elem), deg2rad(orbit5Elem), orbit6Elem, frame);
                
            otherwise
                error('Unknown element set type: %s', class(elemSetEnum));
        end

        action.orbitModel = orbitModel;
        
        %inherit time
        action.inheritTime = logical(handles.inheritTimeCheckbox.Value);
        switch handles.inheritTimeButtonGroup.SelectedObject
            case handles.inheritTimeFromPrevStateRadioBtn
                action.inheritTimeFrom = InheritStateEnum.InheritFromLastState;
                action.inheritTimeFromEvent = LaunchVehicleEvent.empty(1,0);
                
            case handles.inheritTimeFromSpecEvtRadioBtn
                action.inheritTimeFrom = InheritStateEnum.InheritFromSpecifiedEvent;
                action.inheritTimeFromEvent = lvdData.script.getEventForInd(handles.inheritTimeSpecEvtCombo.Value);
                
            otherwise
                error('Unknown UI widget handle for time inheritence selection: %s', handles.inheritTimeButtonGroup.SelectedObject.Tag);
        end
        
        %inherit pos/vel state
        action.inheritPosVel = logical(handles.inheritStateCheckbox.Value);
        switch handles.inheritStateButtonGroup.SelectedObject
            case handles.inheritStateFromPrevStateRadioBtn
                action.inheritPosVelFrom = InheritStateEnum.InheritFromLastState;
                action.inheritPosVelFromEvent = LaunchVehicleEvent.empty(1,0);
                
            case handles.inheritStateFromSpecEvtRadioBtn
                action.inheritPosVelFrom = InheritStateEnum.InheritFromSpecifiedEvent;
                action.inheritPosVelFromEvent = lvdData.script.getEventForInd(handles.inheritStateSpecEvtCombo.Value);
                
            otherwise
                error('Unknown UI widget handle for pos/vel state inheritence selection: %s', handles.inheritStateButtonGroup.SelectedObject.Tag);
        end
        
        %inherit stage states
        action.inheritStageStates = logical(handles.inheritStageStatesCheckbox.Value);
        switch handles.inheritStageStatesButtonGroup.SelectedObject
            case handles.inheritStageStatesFromPrevStateRadioBtn
                action.inheritStageStatesFrom = InheritStateEnum.InheritFromLastState;
                action.inheritStageStatesFromEvent = LaunchVehicleEvent.empty(1,0);
                
            case handles.inheritStageStatesFromSpecEvtRadioBtn
                action.inheritStageStatesFrom = InheritStateEnum.InheritFromSpecifiedEvent;
                action.inheritStageStatesFromEvent = lvdData.script.getEventForInd(handles.inheritStageStatesSpecEvtCombo.Value);
                
            otherwise
                error('Unknown UI widget handle for stage state inheritence selection: %s', handles.inheritStageStatesButtonGroup.SelectedObject.Tag);
        end
        
        %inherit other state elements
        action.inheritStateElems = logical(handles.inheritOtherStateElementsCheckbox.Value);
        switch handles.inheritOtherStateElementsButtonGroup.SelectedObject
            case handles.inheritOtherStateElementsFromPrevStateRadioBtn
                action.inheritStateElemsFrom = InheritStateEnum.InheritFromLastState;
                action.inheritStateElemsFromEvent = LaunchVehicleEvent.empty(1,0);
                
            case handles.inheritOtherStateElementsFromSpecEvtRadioBtn
                action.inheritStateElemsFrom = InheritStateEnum.InheritFromSpecifiedEvent;
                action.inheritStateElemsFromEvent = lvdData.script.getEventForInd(handles.inheritOtherStateElementsEvtCombo.Value);
                
            otherwise
                error('Unknown UI widget handle for other state element inheritence selection: %s', handles.inheritOtherStateElementsButtonGroup.SelectedObject.Tag);
        end
        
        %Vars
        optVar = action.optVar;
        if(not(isempty(optVar)))
            lvdData.optimizer.vars.removeVariable(optVar);
        end
        optVar = SetKinematicStateActionVariable(action);
                
        optUt         = logical(handles.optUtCheckbox.Value) && not(action.inheritTime);
        optOrbit1Elem = logical(handles.optOrbit1Checkbox.Value) && not(action.inheritPosVel);
        optOrbit2Elem = logical(handles.optOrbit2Checkbox.Value) && not(action.inheritPosVel);
        optOrbit3Elem = logical(handles.optOrbit3Checkbox.Value) && not(action.inheritPosVel);
        optOrbit4Elem = logical(handles.optOrbit4Checkbox.Value) && not(action.inheritPosVel);
        optOrbit5Elem = logical(handles.optOrbit5Checkbox.Value) && not(action.inheritPosVel);
        optOrbit6Elem = logical(handles.optOrbit6Checkbox.Value) && not(action.inheritPosVel);
        
        useTf = [optUt optOrbit1Elem optOrbit2Elem optOrbit3Elem optOrbit4Elem optOrbit5Elem optOrbit6Elem];
        optVar.setUseTfForVariable(useTf);
        lvdData.optimizer.vars.addVariable(optVar);
        
        utLb = str2double(handles.utLbText.String);
        orbit1ElemLb = str2double(handles.orbit1LbText.String);
        orbit2ElemLb = str2double(handles.orbit2LbText.String);
        orbit3ElemLb = str2double(handles.orbit3LbText.String);
        orbit4ElemLb = str2double(handles.orbit4LbText.String);
        orbit5ElemLb = str2double(handles.orbit5LbText.String);
        orbit6ElemLb = str2double(handles.orbit6LbText.String);
        
        utUb = str2double(handles.utUbText.String);
        orbit1ElemUb = str2double(handles.orbit1UbText.String);
        orbit2ElemUb = str2double(handles.orbit2UbText.String);
        orbit3ElemUb = str2double(handles.orbit3UbText.String);
        orbit4ElemUb = str2double(handles.orbit4UbText.String);
        orbit5ElemUb = str2double(handles.orbit5UbText.String);
        orbit6ElemUb = str2double(handles.orbit6UbText.String);
        
        switch elemSetEnum
            case ElementSetEnum.CartesianElements
                lb = [utLb orbit1ElemLb orbit2ElemLb orbit3ElemLb orbit4ElemLb orbit5ElemLb orbit6ElemLb];
                ub = [utUb orbit1ElemUb orbit2ElemUb orbit3ElemUb orbit4ElemUb orbit5ElemUb orbit6ElemUb];
                
            case ElementSetEnum.KeplerianElements
                lb = [utLb orbit1ElemLb orbit2ElemLb deg2rad(orbit3ElemLb) deg2rad(orbit4ElemLb) deg2rad(orbit5ElemLb) deg2rad(orbit6ElemLb)];
                ub = [utUb orbit1ElemUb orbit2ElemUb deg2rad(orbit3ElemUb) deg2rad(orbit4ElemUb) deg2rad(orbit5ElemUb) deg2rad(orbit6ElemUb)];
                
            case ElementSetEnum.GeographicElements
                lb = [utLb deg2rad(orbit1ElemLb) deg2rad(orbit2ElemLb) orbit3ElemLb deg2rad(orbit4ElemLb) deg2rad(orbit5ElemLb) orbit6ElemLb];
                ub = [utUb deg2rad(orbit1ElemUb) deg2rad(orbit2ElemUb) orbit3ElemUb deg2rad(orbit4ElemUb) deg2rad(orbit5ElemUb) orbit6ElemUb];
                
            case ElementSetEnum.UniversalElements
                lb = [utLb orbit1ElemLb orbit2ElemLb deg2rad(orbit3ElemLb) deg2rad(orbit4ElemLb) deg2rad(orbit5ElemLb) orbit6ElemLb];
                ub = [utUb orbit1ElemUb orbit2ElemUb deg2rad(orbit3ElemUb) deg2rad(orbit4ElemUb) deg2rad(orbit5ElemUb) orbit6ElemUb];
                
            otherwise
                error('Unknown element set type: %s', class(elemSetEnum));
        end
        
        for(i=1:length(lb)) %#ok<*NO4LP>
            if(lb(i) > ub(i))
                temp1 = lb(i);
                temp2 = ub(i);
                
                lb(i) = temp2;
                ub(i) = temp1;
            end
        end
        
        optVar.setBndsForVariable(lb, ub);
        
        varargout{1} = true;
        close(handles.lvd_EditActionSetKinematicStateGUI);
    end 
    
function [orbitModel, elemSetEnum] = getCurrentElemSetFromExistingValues(handles)
        contents = cellstr(get(handles.elementSetCombo,'String'));
        selElemSet = contents{get(handles.elementSetCombo,'Value')};
        elemSetEnum = ElementSetEnum.getEnumForListboxStr(selElemSet);
                
        time = str2double(handles.utText.String);
        
        orbit1Elem = str2double(handles.orbit1Text.String);
        orbit2Elem = str2double(handles.orbit2Text.String);
        orbit3Elem = str2double(handles.orbit3Text.String);
        orbit4Elem = str2double(handles.orbit4Text.String);
        orbit5Elem = str2double(handles.orbit5Text.String);
        orbit6Elem = str2double(handles.orbit6Text.String);
        
        curElemSet = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet');
        frame = curElemSet.frame;
        
        switch elemSetEnum
            case ElementSetEnum.CartesianElements
                orbitModel = CartesianElementSet(time, [orbit1Elem; orbit2Elem; orbit3Elem], [orbit4Elem; orbit5Elem; orbit6Elem], frame);
                
            case ElementSetEnum.KeplerianElements
                orbitModel = KeplerianElementSet(time, orbit1Elem, orbit2Elem, deg2rad(orbit3Elem), deg2rad(orbit4Elem), deg2rad(orbit5Elem), deg2rad(orbit6Elem), frame);
                
            case ElementSetEnum.GeographicElements
                orbitModel = GeographicElementSet(time, deg2rad(orbit1Elem), deg2rad(orbit2Elem), orbit3Elem, deg2rad(orbit4Elem), deg2rad(orbit5Elem), orbit6Elem, frame);
                
            case ElementSetEnum.UniversalElements
                orbitModel = UniversalElementSet(time, orbit1Elem, orbit2Elem, deg2rad(orbit3Elem), deg2rad(orbit4Elem), deg2rad(orbit5Elem), orbit6Elem, frame);
                
            otherwise
                error('Unknown element set type: %s', class(elemSetEnum));
        end
    
function bodyInfo = getSelectedBodyInfo(handles)
% 	lvdData = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'lvdData');
%     celBodyData = lvdData.celBodyData;
    
    curElemSet = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet');
    bodyInfo = curElemSet.frame.getOriginBody();

%     bodyStr = handles.centralBodyCombo.String;
%     bodyName = lower(strtrim(bodyStr{handles.centralBodyCombo.Value}));
%     bodyInfo = celBodyData.(bodyName);
    

function errMsg = validateInputs(handles)
	lvdData = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'lvdData');

    errMsg = {};
    bodyInfo = getSelectedBodyInfo(handles);
    
    if(handles.inheritTimeCheckbox.Value == 0)
        ut = str2double(get(handles.utText,'String'));
        enteredStr = get(handles.utText,'String');
        numberName = 'Epoch (UT)';
        lb = 0;
        ub = Inf;
        isInt = false;
        errMsg = validateNumber(ut, numberName, lb, ub, isInt, errMsg, enteredStr);
    end
    
    if(handles.inheritTimeCheckbox.Value == 0 && handles.optUtCheckbox.Value)
        utLb = str2double(get(handles.utLbText,'String'));
        enteredStr = get(handles.utLbText,'String');
        numberName = 'Epoch (UT) (Lower Bound)';
        lb = 0;
        ub = Inf;
        isInt = false;
        errMsg = validateNumber(utLb, numberName, lb, ub, isInt, errMsg, enteredStr);

        utUb = str2double(get(handles.utUbText,'String'));
        enteredStr = get(handles.utUbText,'String');
        numberName = 'Epoch (UT) (Upper Bound)';
        lb = 0;
        ub = Inf;
        isInt = false;
        errMsg = validateNumber(utUb, numberName, lb, ub, isInt, errMsg, enteredStr);

        if(utLb < utUb)
            ut = str2double(get(handles.utText,'String'));
            enteredStr = get(handles.utText,'String');
            numberName = 'Epoch (UT)';
            isInt = false;
            errMsg = validateNumber(ut, numberName, utLb, utUb, isInt, errMsg, enteredStr);
        else
            errMsg{end+1} = sprintf('%s lower bound must be less than the upper bound.', 'Epoch (UT)');
        end
    end
    
    if(handles.inheritStateCheckbox.Value == 0)
        contents = cellstr(get(handles.elementSetCombo,'String'));
        selElemSet = contents{get(handles.elementSetCombo,'Value')};
        elemSetEnum = ElementSetEnum.getEnumForListboxStr(selElemSet);

        checkElementValues = ones(1,6);
        checkElementBnds = [handles.optOrbit1Checkbox.Value, ...
                            handles.optOrbit2Checkbox.Value, ...
                            handles.optOrbit3Checkbox.Value, ...
                            handles.optOrbit4Checkbox.Value, ...
                            handles.optOrbit5Checkbox.Value, ...
                            handles.optOrbit6Checkbox.Value];

        switch elemSetEnum
            case ElementSetEnum.CartesianElements
                errMsg = CartesianElementSet.validateInputOrbit(errMsg, handles.orbit1Text, handles.orbit2Text, handles.orbit3Text, handles.orbit4Text, handles.orbit5Text, handles.orbit6Text, bodyInfo, '', checkElementValues);
                errMsg = CartesianElementSet.validateInputOrbit(errMsg, handles.orbit1LbText, handles.orbit2LbText, handles.orbit3LbText, handles.orbit4LbText, handles.orbit5LbText, handles.orbit6LbText, bodyInfo, 'Lower', checkElementBnds);
                errMsg = CartesianElementSet.validateInputOrbit(errMsg, handles.orbit1UbText, handles.orbit2UbText, handles.orbit3UbText, handles.orbit4UbText, handles.orbit5UbText, handles.orbit6UbText, bodyInfo, 'Upper', checkElementBnds);

            case ElementSetEnum.KeplerianElements
                errMsg = KeplerianElementSet.validateInputOrbit(errMsg, handles.orbit1Text, handles.orbit2Text, handles.orbit3Text, handles.orbit4Text, handles.orbit5Text, handles.orbit6Text, bodyInfo, '', checkElementValues);
                errMsg = KeplerianElementSet.validateInputOrbit(errMsg, handles.orbit1LbText, handles.orbit2LbText, handles.orbit3LbText, handles.orbit4LbText, handles.orbit5LbText, handles.orbit6LbText, bodyInfo, 'Lower', checkElementBnds);
                errMsg = KeplerianElementSet.validateInputOrbit(errMsg, handles.orbit1UbText, handles.orbit2UbText, handles.orbit3UbText, handles.orbit4UbText, handles.orbit5UbText, handles.orbit6UbText, bodyInfo, 'Upper', checkElementBnds);

            case ElementSetEnum.GeographicElements
                errMsg = GeographicElementSet.validateInputOrbit(errMsg, handles.orbit1Text, handles.orbit2Text, handles.orbit3Text, handles.orbit4Text, handles.orbit5Text, handles.orbit6Text, bodyInfo, '', checkElementValues);
                errMsg = GeographicElementSet.validateInputOrbit(errMsg, handles.orbit1LbText, handles.orbit2LbText, handles.orbit3LbText, handles.orbit4LbText, handles.orbit5LbText, handles.orbit6LbText, bodyInfo, 'Lower', checkElementBnds);
                errMsg = GeographicElementSet.validateInputOrbit(errMsg, handles.orbit1UbText, handles.orbit2UbText, handles.orbit3UbText, handles.orbit4UbText, handles.orbit5UbText, handles.orbit6UbText, bodyInfo, 'Upper', checkElementBnds);

            case ElementSetEnum.UniversalElements
                errMsg = UniversalElementSet.validateInputOrbit(errMsg, handles.orbit1Text, handles.orbit2Text, handles.orbit3Text, handles.orbit4Text, handles.orbit5Text, handles.orbit6Text, bodyInfo, '', checkElementValues);
                errMsg = UniversalElementSet.validateInputOrbit(errMsg, handles.orbit1LbText, handles.orbit2LbText, handles.orbit3LbText, handles.orbit4LbText, handles.orbit5LbText, handles.orbit6LbText, bodyInfo, 'Lower', checkElementBnds);
                errMsg = UniversalElementSet.validateInputOrbit(errMsg, handles.orbit1UbText, handles.orbit2UbText, handles.orbit3UbText, handles.orbit4UbText, handles.orbit5UbText, handles.orbit6UbText, bodyInfo, 'Upper', checkElementBnds);

            otherwise
                error('Unknown element set type: %s', class(elemSetEnum));
        end

        hVal = [handles.orbit1Text, handles.orbit2Text, handles.orbit3Text, handles.orbit4Text, handles.orbit5Text, handles.orbit6Text];
        hLb = [handles.orbit1LbText, handles.orbit2LbText, handles.orbit3LbText, handles.orbit4LbText, handles.orbit5LbText, handles.orbit6LbText];
        hUb = [handles.orbit1UbText, handles.orbit2UbText, handles.orbit3UbText, handles.orbit4UbText, handles.orbit5UbText, handles.orbit6UbText];

        elemNames = elemSetEnum.elemNames;

        for(i=1:length(hVal))
            if(checkElementBnds(i) == 1)
                lb = str2double(get(hLb(i),'String'));
                ub = str2double(get(hUb(i),'String'));

                if(lb <= ub)
                    value = str2double(get(hVal(i),'String'));
                    enteredStr = get(hVal(i),'String');
                    numberName = [elemNames{i}];
                    isInt = false;
                    errMsg = validateNumber(value, numberName, lb, ub, isInt, errMsg, enteredStr);
                else
                    errMsg{end+1} = sprintf('%s lower bound must be less than the upper bound.', elemNames{i}); %#ok<AGROW>
                end
            end
        end
    end


% --- Executes on button press in saveAndCloseButton.
function saveAndCloseButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveAndCloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    errMsg = validateInputs(handles);

    if(isempty(errMsg))
        uiresume(handles.lvd_EditActionSetKinematicStateGUI);
    else
        msgbox(errMsg,'Errors were found while editing the state.','error');
    end

% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(handles.lvd_EditActionSetKinematicStateGUI);

% --- Executes on button press in inheritStateCheckbox.
function inheritStateCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to inheritStateCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of inheritStateCheckbox
    if(not(get(hObject,'Value')))
        handles.orbit1Text.Enable = 'on';
        handles.optOrbit1Checkbox.Enable = 'on';
        
        handles.orbit2Text.Enable = 'on';
        handles.optOrbit2Checkbox.Enable = 'on';
        
        handles.orbit3Text.Enable = 'on';
        handles.optOrbit3Checkbox.Enable = 'on';
        
        handles.orbit4Text.Enable = 'on';
        handles.optOrbit4Checkbox.Enable = 'on';
        
        handles.orbit5Text.Enable = 'on';
        handles.optOrbit5Checkbox.Enable = 'on';
        
        handles.orbit6Text.Enable = 'on';
        handles.optOrbit6Checkbox.Enable = 'on';
        
        optOrbit1Checkbox_Callback(handles.optOrbit1Checkbox, [], handles);
        optOrbit2Checkbox_Callback(handles.optOrbit2Checkbox, [], handles);
        optOrbit3Checkbox_Callback(handles.optOrbit3Checkbox, [], handles);
        optOrbit4Checkbox_Callback(handles.optOrbit4Checkbox, [], handles);
        optOrbit5Checkbox_Callback(handles.optOrbit5Checkbox, [], handles);
        optOrbit6Checkbox_Callback(handles.optOrbit6Checkbox, [], handles);
        
        handles.inheritStateFromPrevStateRadioBtn.Enable = 'off';
        handles.inheritStateFromSpecEvtRadioBtn.Enable = 'off';
        handles.inheritStateSpecEvtCombo.Enable = 'off';
    else
        handles.orbit1Text.Enable = 'off';
        handles.optOrbit1Checkbox.Enable = 'off';
        
        handles.orbit2Text.Enable = 'off';
        handles.optOrbit2Checkbox.Enable = 'off';
        
        handles.orbit3Text.Enable = 'off';
        handles.optOrbit3Checkbox.Enable = 'off';
        
        handles.orbit4Text.Enable = 'off';
        handles.optOrbit4Checkbox.Enable = 'off';
        
        handles.orbit5Text.Enable = 'off';
        handles.optOrbit5Checkbox.Enable = 'off';
        
        handles.orbit6Text.Enable = 'off';
        handles.optOrbit6Checkbox.Enable = 'off';
        
        handles.orbit1LbText.Enable = 'off';
        handles.orbit1UbText.Enable = 'off';
        
        handles.orbit2LbText.Enable = 'off';
        handles.orbit2UbText.Enable = 'off';
        
        handles.orbit3LbText.Enable = 'off';
        handles.orbit3UbText.Enable = 'off';
        
        handles.orbit4LbText.Enable = 'off';
        handles.orbit4UbText.Enable = 'off';
        
        handles.orbit5LbText.Enable = 'off';
        handles.orbit5UbText.Enable = 'off';
        
        handles.orbit6LbText.Enable = 'off';
        handles.orbit6UbText.Enable = 'off';
        
        handles.inheritStateFromPrevStateRadioBtn.Enable = 'on';
        handles.inheritStateFromSpecEvtRadioBtn.Enable = 'on';
        inheritStateButtonGroup_SelectionChangedFcn(handles.inheritStateButtonGroup.SelectedObject, [], handles);
    end
    

% --- Executes on button press in inheritTimeCheckbox.
function inheritTimeCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to inheritTimeCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of inheritTimeCheckbox
    if(not(get(hObject,'Value')))
        handles.utText.Enable = 'on';
        handles.optUtCheckbox.Enable = 'on';
        
        optUtCheckbox_Callback(handles.optUtCheckbox, [], handles);
        
        handles.inheritTimeFromPrevStateRadioBtn.Enable = 'off';
        handles.inheritTimeFromSpecEvtRadioBtn.Enable = 'off';
        handles.inheritTimeSpecEvtCombo.Enable = 'off';
    else
        handles.utText.Enable = 'off';
        handles.optUtCheckbox.Enable = 'off';
        
        handles.utLbText.Enable = 'off';
        handles.utUbText.Enable = 'off';
        
        handles.inheritTimeFromPrevStateRadioBtn.Enable = 'on';
        handles.inheritTimeFromSpecEvtRadioBtn.Enable = 'on';
        inheritTimeButtonGroup_SelectionChangedFcn(handles.inheritTimeButtonGroup.SelectedObject, [], handles);
    end
    
    

% --- Executes on selection change in elementSetCombo.
function elementSetCombo_Callback(hObject, eventdata, handles)
% hObject    handle to elementSetCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns elementSetCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from elementSetCombo
    contents = cellstr(get(hObject,'String'));
    sel = contents{get(hObject,'Value')};
    [~, elemSetEnum] = ElementSetEnum.getIndForName(sel);
    
    elemNames = elemSetEnum.elemNames;
    unitNames = elemSetEnum.unitNames;
    
    handles.orbit1Label.String = elemNames{1};
    handles.orbit2Label.String = elemNames{2};
    handles.orbit3Label.String = elemNames{3};
    handles.orbit4Label.String = elemNames{4};
    handles.orbit5Label.String = elemNames{5};
    handles.orbit6Label.String = elemNames{6};
    
    handles.orbit1UnitLabel.String = unitNames{1};
    handles.orbit2UnitLabel.String = unitNames{2};
    handles.orbit3UnitLabel.String = unitNames{3};
    handles.orbit4UnitLabel.String = unitNames{4};
    handles.orbit5UnitLabel.String = unitNames{5};
    handles.orbit6UnitLabel.String = unitNames{6};
    
    curElemSet = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet');
    
    try
        switch elemSetEnum
            case ElementSetEnum.CartesianElements
                newElemSet = curElemSet.convertToCartesianElementSet();

            case ElementSetEnum.KeplerianElements
                newElemSet = curElemSet.convertToKeplerianElementSet();

            case ElementSetEnum.GeographicElements
                newElemSet = curElemSet.convertToGeographicElementSet();
                
            case ElementSetEnum.UniversalElements
                newElemSet = curElemSet.convertToUniversalElementSet();

            otherwise
                error('Unknown element set type: %s', class(elemSetEnum));
        end
        
        elemVect = newElemSet.getElementVector();
        
        if(any(isnan(elemVect)) || any(not(isfinite(elemVect))))
            error('State conversion resulted in NaN or Inf');
        end        
        
        handles.orbit1Text.String = fullAccNum2Str(elemVect(1));
        handles.orbit2Text.String = fullAccNum2Str(elemVect(2));
        handles.orbit3Text.String = fullAccNum2Str(elemVect(3));
        handles.orbit4Text.String = fullAccNum2Str(elemVect(4));
        handles.orbit5Text.String = fullAccNum2Str(elemVect(5));
        handles.orbit6Text.String = fullAccNum2Str(elemVect(6));

        setappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet', newElemSet);
        
    catch ME
        updateValuesInState(handles);
        msgbox('Error converting state to new element set.','Conversion Error','error');
    end

% --- Executes during object creation, after setting all properties.
function elementSetCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to elementSetCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function updateStateDueToFrameChange(handles, newFrame)
    lvdData = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'lvdData');
    celBodyData = lvdData.celBodyData;

    curElemSet = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet');
    
    contents = cellstr(get(handles.refFrameTypeCombo,'String'));
    selFrameType = contents{get(handles.refFrameTypeCombo,'Value')};
    refFrameEnum = ReferenceFrameEnum.getEnumForListboxStr(selFrameType);
    
    if(not(isempty(newFrame)) && newFrame.typeEnum ~= refFrameEnum)
        refFrameEnum = newFrame.typeEnum;
        handles.refFrameTypeCombo.Value = ReferenceFrameEnum.getIndForName(refFrameEnum.name);
    end
    
    switch refFrameEnum
        case ReferenceFrameEnum.BodyCenteredInertial
            if(isempty(newFrame))
                bodyInfo = getSelectedBodyInfo(handles);
            else
                bodyInfo = newFrame.getOriginBody();
            end            
            
            newFrame = bodyInfo.getBodyCenteredInertialFrame();

        case ReferenceFrameEnum.BodyFixedRotating
            if(isempty(newFrame))
                bodyInfo = getSelectedBodyInfo(handles);
            else
                bodyInfo = newFrame.getOriginBody();
            end
            
            newFrame = bodyInfo.getBodyFixedFrame();
            
        case ReferenceFrameEnum.TwoBodyRotating            
            if(isempty(newFrame))
                bodyInfo = getSelectedBodyInfo(handles);
                if(not(isempty(bodyInfo.childrenBodyInfo)))
                    primaryBody = bodyInfo;
                    secondaryBody = bodyInfo.childrenBodyInfo(1);
                else
                    primaryBody = bodyInfo.getParBodyInfo();
                    secondaryBody = bodyInfo;
                end
                
                originPt = TwoBodyRotatingFrameOriginEnum.Primary;
                
                newFrame = TwoBodyRotatingFrame(primaryBody, secondaryBody, originPt, celBodyData);
            else
                newFrame = TwoBodyRotatingFrame(newFrame.primaryBodyInfo, newFrame.secondaryBodyInfo, newFrame.originPt, celBodyData);
            end
            
        case ReferenceFrameEnum.UserDefined
            if(isempty(newFrame))
                numFrames = lvdData.geometry.refFrames.getNumRefFrames();
                if(numFrames >= 1)
                    geometricFrame = AbstractGeometricRefFrame.empty(1,0);
                    for(i=1:numFrames)
                        frame = lvdData.geometry.refFrames.getRefFrameAtInd(i);
                        if(frame.isVehDependent() == false)
                            geometricFrame = frame;
                            break;
                        end
                    end

                    if(not(isempty(geometricFrame)))
                        newFrame = UserDefinedGeometricFrame(geometricFrame, lvdData);
                    else
                        bodyInfo = getSelectedBodyInfo(handles);
                        newFrame = bodyInfo.getBodyCenteredInertialFrame();
                        
                        warndlg('There are no geometric frames available which are not dependent on vehicle properties.  A body-centered inertial frame will be selected instead.');
                    end
                else
                    bodyInfo = getSelectedBodyInfo(handles);
                    newFrame = bodyInfo.getBodyCenteredInertialFrame();
                    
                    warndlg('There are no geometric frames available which are not dependent on vehicle properties.  A body-centered inertial frame will be selected instead.');
                end
                
            else
                newFrame = UserDefinedGeometricFrame(newFrame.geometricFrame, lvdData);
            end

        otherwise
            error('Unknown reference frame type: %s', string(refFrameEnum));                
    end
    
    if(not(isempty(newFrame)) && newFrame.typeEnum ~= refFrameEnum)
        refFrameEnum = newFrame.typeEnum;
        handles.refFrameTypeCombo.Value = ReferenceFrameEnum.getIndForName(refFrameEnum.name);
    end
    
    try
        newElemSet = curElemSet.convertToFrame(newFrame);

        elemVect = newElemSet.getElementVector();
        
        if(any(isnan(elemVect)) || any(not(isfinite(elemVect))))
            error('State conversion resulted in NaN');
        end
        
        handles.orbit1Text.String = fullAccNum2Str(elemVect(1));
        handles.orbit2Text.String = fullAccNum2Str(elemVect(2));
        handles.orbit3Text.String = fullAccNum2Str(elemVect(3));
        handles.orbit4Text.String = fullAccNum2Str(elemVect(4));
        handles.orbit5Text.String = fullAccNum2Str(elemVect(5));
        handles.orbit6Text.String = fullAccNum2Str(elemVect(6));

        setappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet', newElemSet);
    catch ME
        updateValuesInState(handles);
        msgbox('Error converting state to new frame.','Conversion Error','error');
    end
    
    handles.setFrameOptionsButton.TooltipString = sprintf('Current Frame: %s', newFrame.getNameStr()); 
    
function updateValuesInState(handles)
    curElemSet = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet');
    newElemSet = curElemSet;
    
    time = str2double(handles.utText.String);
    orbit1Elem = str2double(handles.orbit1Text.String);
    orbit2Elem = str2double(handles.orbit2Text.String);
    orbit3Elem = str2double(handles.orbit3Text.String);
    orbit4Elem = str2double(handles.orbit4Text.String);
    orbit5Elem = str2double(handles.orbit5Text.String);
    orbit6Elem = str2double(handles.orbit6Text.String);
    
    frame = newElemSet.frame;
	switch newElemSet.typeEnum
        case ElementSetEnum.CartesianElements
            newElemSet = CartesianElementSet(time, [orbit1Elem; orbit2Elem; orbit3Elem], [orbit4Elem; orbit5Elem; orbit6Elem], frame);

        case ElementSetEnum.KeplerianElements
            newElemSet = KeplerianElementSet(time, orbit1Elem, orbit2Elem, deg2rad(orbit3Elem), deg2rad(orbit4Elem), deg2rad(orbit5Elem), deg2rad(orbit6Elem), frame);

        case ElementSetEnum.GeographicElements
            newElemSet = GeographicElementSet(time, deg2rad(orbit1Elem), deg2rad(orbit2Elem), orbit3Elem, deg2rad(orbit4Elem), deg2rad(orbit5Elem), orbit6Elem, frame);
                
        case ElementSetEnum.UniversalElements
            newElemSet = UniversalElementSet(time, orbit1Elem, orbit2Elem, deg2rad(orbit3Elem), deg2rad(orbit4Elem), deg2rad(orbit5Elem), orbit6Elem, frame);
            
        otherwise
            error('Unknown element set type: %s', class(elemSetEnum));
	end
    
    setappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet', newElemSet);


% % --- Executes on selection change in centralBodyCombo.
% function centralBodyCombo_Callback(hObject, eventdata, handles)
% % hObject    handle to centralBodyCombo (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    structure with handles and user data (see GUIDATA)
% 
% % Hints: contents = cellstr(get(hObject,'String')) returns centralBodyCombo contents as cell array
% %        contents{get(hObject,'Value')} returns selected item from centralBodyCombo
%     updateStateDueToFrameChange(handles);
% 
% % --- Executes during object creation, after setting all properties.
% function centralBodyCombo_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to centralBodyCombo (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called
% 
% % Hint: popupmenu controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end


% --- Executes on selection change in refFrameTypeCombo.
function refFrameTypeCombo_Callback(hObject, eventdata, handles)
% hObject    handle to refFrameTypeCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns refFrameTypeCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from refFrameTypeCombo
    updateStateDueToFrameChange(handles, AbstractReferenceFrame.empty(1,0));

% --- Executes during object creation, after setting all properties.
function refFrameTypeCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to refFrameTypeCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function utText_Callback(hObject, eventdata, handles)
% hObject    handle to utText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of utText as text
%        str2double(get(hObject,'String')) returns contents of utText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function utText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to utText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optUtCheckbox.
function optUtCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to optUtCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optUtCheckbox
    if(get(hObject,'Value') && not(get(handles.inheritTimeCheckbox,'Value')))
        handles.utLbText.Enable = 'on';
        handles.utUbText.Enable = 'on';
    else
        handles.utLbText.Enable = 'off';
        handles.utUbText.Enable = 'off';
    end


function utLbText_Callback(hObject, eventdata, handles)
% hObject    handle to utLbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of utLbText as text
%        str2double(get(hObject,'String')) returns contents of utLbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function utLbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to utLbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function utUbText_Callback(hObject, eventdata, handles)
% hObject    handle to utUbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of utUbText as text
%        str2double(get(hObject,'String')) returns contents of utUbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function utUbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to utUbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit1Text_Callback(hObject, eventdata, handles)
% hObject    handle to orbit1Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit1Text as text
%        str2double(get(hObject,'String')) returns contents of orbit1Text as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit1Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit1Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optOrbit1Checkbox.
function optOrbit1Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to optOrbit1Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optOrbit1Checkbox
    if(get(hObject,'Value') && not(get(handles.inheritStateCheckbox,'Value')))
        handles.orbit1LbText.Enable = 'on';
        handles.orbit1UbText.Enable = 'on';
    else
        handles.orbit1LbText.Enable = 'off';
        handles.orbit1UbText.Enable = 'off';
    end


function orbit1LbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit1LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit1LbText as text
%        str2double(get(hObject,'String')) returns contents of orbit1LbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit1LbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit1LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit1UbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit1UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit1UbText as text
%        str2double(get(hObject,'String')) returns contents of orbit1UbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit1UbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit1UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit2Text_Callback(hObject, eventdata, handles)
% hObject    handle to orbit2Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit2Text as text
%        str2double(get(hObject,'String')) returns contents of orbit2Text as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit2Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit2Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optOrbit2Checkbox.
function optOrbit2Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to optOrbit2Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optOrbit2Checkbox
    if(get(hObject,'Value') && not(get(handles.inheritStateCheckbox,'Value')))
        handles.orbit2LbText.Enable = 'on';
        handles.orbit2UbText.Enable = 'on';
    else
        handles.orbit2LbText.Enable = 'off';
        handles.orbit2UbText.Enable = 'off';
    end



function orbit2LbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit2LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit2LbText as text
%        str2double(get(hObject,'String')) returns contents of orbit2LbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit2LbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit2LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit2UbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit2UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit2UbText as text
%        str2double(get(hObject,'String')) returns contents of orbit2UbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit2UbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit2UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit3Text_Callback(hObject, eventdata, handles)
% hObject    handle to orbit3Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit3Text as text
%        str2double(get(hObject,'String')) returns contents of orbit3Text as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit3Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit3Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optOrbit3Checkbox.
function optOrbit3Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to optOrbit3Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optOrbit3Checkbox
    if(get(hObject,'Value') && not(get(handles.inheritStateCheckbox,'Value')))
        handles.orbit3LbText.Enable = 'on';
        handles.orbit3UbText.Enable = 'on';
    else
        handles.orbit3LbText.Enable = 'off';
        handles.orbit3UbText.Enable = 'off';
    end



function orbit3LbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit3LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit3LbText as text
%        str2double(get(hObject,'String')) returns contents of orbit3LbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit3LbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit3LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit3UbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit3UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit3UbText as text
%        str2double(get(hObject,'String')) returns contents of orbit3UbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit3UbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit3UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit4Text_Callback(hObject, eventdata, handles)
% hObject    handle to orbit4Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit4Text as text
%        str2double(get(hObject,'String')) returns contents of orbit4Text as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit4Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit4Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optOrbit4Checkbox.
function optOrbit4Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to optOrbit4Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optOrbit4Checkbox
    if(get(hObject,'Value') && not(get(handles.inheritStateCheckbox,'Value')))
        handles.orbit4LbText.Enable = 'on';
        handles.orbit4UbText.Enable = 'on';
    else
        handles.orbit4LbText.Enable = 'off';
        handles.orbit4UbText.Enable = 'off';
    end


function orbit4LbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit4LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit4LbText as text
%        str2double(get(hObject,'String')) returns contents of orbit4LbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit4LbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit4LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit4UbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit4UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit4UbText as text
%        str2double(get(hObject,'String')) returns contents of orbit4UbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit4UbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit4UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit5Text_Callback(hObject, eventdata, handles)
% hObject    handle to orbit5Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit5Text as text
%        str2double(get(hObject,'String')) returns contents of orbit5Text as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit5Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit5Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optOrbit5Checkbox.
function optOrbit5Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to optOrbit5Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optOrbit5Checkbox
    if(get(hObject,'Value') && not(get(handles.inheritStateCheckbox,'Value')))
        handles.orbit5LbText.Enable = 'on';
        handles.orbit5UbText.Enable = 'on';
    else
        handles.orbit5LbText.Enable = 'off';
        handles.orbit5UbText.Enable = 'off';
    end


function orbit5LbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit5LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit5LbText as text
%        str2double(get(hObject,'String')) returns contents of orbit5LbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit5LbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit5LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit5UbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit5UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit5UbText as text
%        str2double(get(hObject,'String')) returns contents of orbit5UbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit5UbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit5UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit6Text_Callback(hObject, eventdata, handles)
% hObject    handle to orbit6Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit6Text as text
%        str2double(get(hObject,'String')) returns contents of orbit6Text as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit6Text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit6Text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in optOrbit6Checkbox.
function optOrbit6Checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to optOrbit6Checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of optOrbit6Checkbox
    if(get(hObject,'Value') && not(get(handles.inheritStateCheckbox,'Value')))
        handles.orbit6LbText.Enable = 'on';
        handles.orbit6UbText.Enable = 'on';
    else
        handles.orbit6LbText.Enable = 'off';
        handles.orbit6UbText.Enable = 'off';
    end


function orbit6LbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit6LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit6LbText as text
%        str2double(get(hObject,'String')) returns contents of orbit6LbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit6LbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit6LbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function orbit6UbText_Callback(hObject, eventdata, handles)
% hObject    handle to orbit6UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of orbit6UbText as text
%        str2double(get(hObject,'String')) returns contents of orbit6UbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function orbit6UbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to orbit6UbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on lvd_EditActionSetKinematicStateGUI or any of its controls.
function lvd_EditActionSetKinematicStateGUI_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to lvd_EditActionSetKinematicStateGUI (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
    switch(eventdata.Key)
        case 'return'
            saveAndCloseButton_Callback(handles.saveAndCloseButton, [], handles);
        case 'enter'
            saveAndCloseButton_Callback(handles.saveAndCloseButton, [], handles);
        case 'escape'
            close(handles.lvd_EditActionSetKinematicStateGUI);
    end


% --------------------------------------------------------------------
function getOrbitFromSFSFileContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to getOrbitFromSFSFileContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	contents = cellstr(get(handles.refFrameTypeCombo,'String'));
    selFrameType = contents{get(handles.refFrameTypeCombo,'Value')};
    enum = ReferenceFrameEnum.getEnumForListboxStr(selFrameType);
    if(not(enum == ReferenceFrameEnum.BodyCenteredInertial))
        enum = ReferenceFrameEnum.BodyCenteredInertial;
        ind = ReferenceFrameEnum.getIndForName(enum.name);
        handles.refFrameTypeCombo.Value = ind;
        refFrameTypeCombo_Callback(handles.refFrameTypeCombo, [], handles);
    end  

    contents = cellstr(get(handles.elementSetCombo,'String'));
    selOrbitType = contents{get(handles.elementSetCombo,'Value')};
    [~,enum] = ElementSetEnum.getIndForName(selOrbitType);
    if(not(enum == ElementSetEnum.KeplerianElements))
        enum = ElementSetEnum.KeplerianElements;
        ind = ElementSetEnum.getIndForName(enum.name);
        handles.elementSetCombo.Value = ind;
        elementSetCombo_Callback(handles.elementSetCombo, [], handles);
    end

    refBodyID = orbitPanelGetOrbitFromSFSContextCallBack([], handles.orbit1Text, handles.orbit2Text, handles.orbit3Text, handles.orbit4Text, handles.orbit5Text, handles.orbit6Text, handles.utText);
    tru = computeTrueAnomFromMean(deg2rad(str2double(get(handles.orbit6Text,'String'))), str2double(get(handles.orbit2Text,'String')));
    set(handles.orbit6Text,'String',fullAccNum2Str(rad2deg(tru)));

    if(~isempty(refBodyID) && isnumeric(refBodyID))
        lvdData = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'lvdData');
        celBodyData = lvdData.celBodyData;
        bodyInfo = getBodyInfoByNumber(refBodyID, celBodyData);
        
        curElemSet = getCurrentElemSetFromExistingValues(handles);
        setappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet',curElemSet);
        
%         curElemSet = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet');
        curElemSet.frame.setOriginBody(bodyInfo);
        updateStateDueToFrameChange(handles, AbstractReferenceFrame.empty(1,0));
        
%         value = findValueFromComboBox(bodyInfo.name, handles.centralBodyCombo);
%         set(handles.centralBodyCombo,'Value',value);
    end

% --------------------------------------------------------------------
function getOrbitFromKSPTOTConnectContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to getOrbitFromKSPTOTConnectContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	contents = cellstr(get(handles.refFrameTypeCombo,'String'));
    selFrameType = contents{get(handles.refFrameTypeCombo,'Value')};
    enum = ReferenceFrameEnum.getEnumForListboxStr(selFrameType);
    if(not(enum == ReferenceFrameEnum.BodyCenteredInertial))
        enum = ReferenceFrameEnum.BodyCenteredInertial;
        ind = ReferenceFrameEnum.getIndForName(enum.name);
        handles.refFrameTypeCombo.Value = ind;
        refFrameTypeCombo_Callback(handles.refFrameTypeCombo, [], handles);
    end  

    contents = cellstr(get(handles.elementSetCombo,'String'));
    selOrbitType = contents{get(handles.elementSetCombo,'Value')};
    [~,enum] = ElementSetEnum.getIndForName(selOrbitType);
    if(not(enum == ElementSetEnum.KeplerianElements))
        enum = ElementSetEnum.KeplerianElements;
        ind = ElementSetEnum.getIndForName(enum.name);
        handles.elementSetCombo.Value = ind;
        elementSetCombo_Callback(handles.elementSetCombo, [], handles);
    end
    
    refBodyID = orbitPanelGetOrbitFromKSPTOTConnectCallBack(handles.orbit1Text, handles.orbit2Text, handles.orbit3Text, handles.orbit4Text, handles.orbit5Text, handles.orbit6Text, handles.utText);
    tru = computeTrueAnomFromMean(deg2rad(str2double(get(handles.orbit6Text,'String'))), str2double(get(handles.orbit2Text,'String')));
    set(handles.orbit6Text,'String',fullAccNum2Str(rad2deg(tru)));
    
    if(~isempty(refBodyID) && isnumeric(refBodyID))
        lvdData = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'lvdData');
        celBodyData = lvdData.celBodyData;
        bodyInfo = getBodyInfoByNumber(refBodyID, celBodyData);
        
        curElemSet = getCurrentElemSetFromExistingValues(handles);
        setappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet',curElemSet);
        
%         curElemSet = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet');
        curElemSet.frame.setOriginBody(bodyInfo);
        updateStateDueToFrameChange(handles, AbstractReferenceFrame.empty(1,0));
        
%         value = findValueFromComboBox(bodyInfo.name, handles.centralBodyCombo);
%         set(handles.centralBodyCombo,'Value',value);
    end

% --------------------------------------------------------------------
function getOrbitFromKSPActiveVesselMenu_Callback(hObject, eventdata, handles)
% hObject    handle to getOrbitFromKSPActiveVesselMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	contents = cellstr(get(handles.refFrameTypeCombo,'String'));
    selFrameType = contents{get(handles.refFrameTypeCombo,'Value')};
    enum = ReferenceFrameEnum.getEnumForListboxStr(selFrameType);
    if(not(enum == ReferenceFrameEnum.BodyCenteredInertial))
        enum = ReferenceFrameEnum.BodyCenteredInertial;
        ind = ReferenceFrameEnum.getIndForName(enum.name);
        handles.refFrameTypeCombo.Value = ind;
        refFrameTypeCombo_Callback(handles.refFrameTypeCombo, [], handles);
    end  

    contents = cellstr(get(handles.elementSetCombo,'String'));
    selOrbitType = contents{get(handles.elementSetCombo,'Value')};
    [~,enum] = ElementSetEnum.getIndForName(selOrbitType);
    if(not(enum == ElementSetEnum.KeplerianElements))
        enum = ElementSetEnum.KeplerianElements;
        ind = ElementSetEnum.getIndForName(enum.name);
        handles.elementSetCombo.Value = ind;
        elementSetCombo_Callback(handles.elementSetCombo, [], handles);
    end

    refBodyID = orbitPanelGetOrbitFromKSPTOTConnectActiveVesselCallBack(handles.orbit1Text, handles.orbit2Text, handles.orbit3Text, handles.orbit4Text, handles.orbit5Text, handles.orbit6Text, handles.utText);
    tru = computeTrueAnomFromMean(deg2rad(str2double(get(handles.orbit6Text,'String'))), str2double(get(handles.orbit2Text,'String')));
    set(handles.orbit6Text,'String',fullAccNum2Str(rad2deg(tru)));
    
    if(~isempty(refBodyID) && isnumeric(refBodyID))
        lvdData = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'lvdData');
        celBodyData = lvdData.celBodyData;
        bodyInfo = getBodyInfoByNumber(refBodyID, celBodyData);
        
        curElemSet = getCurrentElemSetFromExistingValues(handles);
        setappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet',curElemSet);
        
%         curElemSet = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet');
        curElemSet.frame.setOriginBody(bodyInfo);
        updateStateDueToFrameChange(handles, AbstractReferenceFrame.empty(1,0));
        
%         value = findValueFromComboBox(bodyInfo.name, handles.centralBodyCombo);
%         set(handles.centralBodyCombo,'Value',value);
    end

% --------------------------------------------------------------------
function copyOrbitToClipboardMenu_Callback(hObject, eventdata, handles)
% hObject    handle to copyOrbitToClipboardMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 	lvdData = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'lvdData');
%     celBodyData = lvdData.celBodyData;
    
%     contents = cellstr(get(handles.centralBodyCombo,'String'));
%     selected = strtrim(contents{get(handles.centralBodyCombo,'Value')});
%     bodyInfo = celBodyData.(lower(selected));

    bodyInfo = getSelectedBodyInfo(handles);

    o1V = handles.orbit1Text.String;
    o2V = handles.orbit2Text.String;
    o3V = handles.orbit3Text.String;
    o4V = handles.orbit4Text.String;
    o5V = handles.orbit5Text.String;
    o6V = handles.orbit6Text.String;
       
	contents = cellstr(get(handles.refFrameTypeCombo,'String'));
    selFrameType = contents{get(handles.refFrameTypeCombo,'Value')};
    enum = ReferenceFrameEnum.getEnumForListboxStr(selFrameType);
    framEnumOrig = enum;
    if(not(enum == ReferenceFrameEnum.BodyCenteredInertial))
        enum = ReferenceFrameEnum.BodyCenteredInertial;
        ind = ReferenceFrameEnum.getIndForName(enum.name);
        handles.refFrameTypeCombo.Value = ind;
        refFrameTypeCombo_Callback(handles.refFrameTypeCombo, [], handles);
    end  

    contents = cellstr(get(handles.elementSetCombo,'String'));
    selOrbitType = contents{get(handles.elementSetCombo,'Value')};
    [~,enum] = ElementSetEnum.getIndForName(selOrbitType);
    elemSetEnumOrig = enum;
    if(not(enum == ElementSetEnum.KeplerianElements))
        enum = ElementSetEnum.KeplerianElements;
        ind = ElementSetEnum.getIndForName(enum.name);
        handles.elementSetCombo.Value = ind;
        elementSetCombo_Callback(handles.elementSetCombo, [], handles);
    end 

    copyOrbitToClipboardFromText(handles.utText, handles.orbit1Text, handles.orbit2Text, ...
                                 handles.orbit3Text, handles.orbit4Text, handles.orbit5Text, ...
                                 handles.orbit6Text, true, bodyInfo.id);
                                
    ind = ElementSetEnum.getIndForName(elemSetEnumOrig.name);
    handles.elementSetCombo.Value = ind;
    elementSetCombo_Callback(handles.elementSetCombo, [], handles);
    
    ind = ReferenceFrameEnum.getIndForName(framEnumOrig.name);
    handles.refFrameTypeCombo.Value = ind;
    refFrameTypeCombo_Callback(handles.refFrameTypeCombo, [], handles);
    
    handles.orbit1Text.String = o1V;
    handles.orbit2Text.String = o2V;
    handles.orbit3Text.String = o3V;
    handles.orbit4Text.String = o4V;
    handles.orbit5Text.String = o5V;
    handles.orbit6Text.String = o6V;

% --------------------------------------------------------------------
function pasteOrbitFromClipboardMenu_Callback(hObject, eventdata, handles)
% hObject    handle to pasteOrbitFromClipboardMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
	contents = cellstr(get(handles.refFrameTypeCombo,'String'));
    selFrameType = contents{get(handles.refFrameTypeCombo,'Value')};
    enum = ReferenceFrameEnum.getEnumForListboxStr(selFrameType);
    if(not(enum == ReferenceFrameEnum.BodyCenteredInertial))
        enum = ReferenceFrameEnum.BodyCenteredInertial;
        ind = ReferenceFrameEnum.getIndForName(enum.name);
        handles.refFrameTypeCombo.Value = ind;
        refFrameTypeCombo_Callback(handles.refFrameTypeCombo, [], handles);
    end  

    contents = cellstr(get(handles.elementSetCombo,'String'));
    selOrbitType = contents{get(handles.elementSetCombo,'Value')};
    [~,enum] = ElementSetEnum.getIndForName(selOrbitType);
    if(not(enum == ElementSetEnum.KeplerianElements))
        enum = ElementSetEnum.KeplerianElements;
        ind = ElementSetEnum.getIndForName(enum.name);
        handles.elementSetCombo.Value = ind;
        elementSetCombo_Callback(handles.elementSetCombo, [], handles);
    end

	lvdData = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'lvdData');
    celBodyData = lvdData.celBodyData;

    bodyInfo = pasteOrbitFromClipboard(handles.utText, handles.orbit1Text, handles.orbit2Text, ...
                                       handles.orbit3Text, handles.orbit4Text, handles.orbit5Text, ...
                                       handles.orbit6Text, true, [], celBodyData);
                                   
	if(not(isempty(bodyInfo)))
        curElemSet = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet');
        curElemSet.frame.setOriginBody(bodyInfo);
        updateStateDueToFrameChange(handles, AbstractReferenceFrame.empty(1,0));
	end

% --------------------------------------------------------------------
function enterUTAsDateTimeContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to enterUTAsDateTimeContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    secUT = enterUTAsDateTimeGUI(str2double(get(gco, 'String')));
    if(secUT >= 0)
        set(gco, 'String', fullAccNum2Str(secUT));
         utText_Callback(handles.utText, eventdata, handles);
    end

% --------------------------------------------------------------------
function epochContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to epochContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function orbitPanelContextMenu_Callback(hObject, eventdata, handles)
% hObject    handle to orbitPanelContextMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in inheritTimeSpecEvtCombo.
function inheritTimeSpecEvtCombo_Callback(hObject, eventdata, handles)
% hObject    handle to inheritTimeSpecEvtCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns inheritTimeSpecEvtCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from inheritTimeSpecEvtCombo


% --- Executes during object creation, after setting all properties.
function inheritTimeSpecEvtCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inheritTimeSpecEvtCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in inheritStateSpecEvtCombo.
function inheritStateSpecEvtCombo_Callback(hObject, eventdata, handles)
% hObject    handle to inheritStateSpecEvtCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns inheritStateSpecEvtCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from inheritStateSpecEvtCombo


% --- Executes during object creation, after setting all properties.
function inheritStateSpecEvtCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inheritStateSpecEvtCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in inheritTimeButtonGroup.
function inheritTimeButtonGroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in inheritTimeButtonGroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(hObject == handles.inheritTimeFromPrevStateRadioBtn)
        handles.inheritTimeSpecEvtCombo.Enable = 'off';
    else
        handles.inheritTimeSpecEvtCombo.Enable = 'on';
    end

% --- Executes when selected object is changed in inheritStateButtonGroup.
function inheritStateButtonGroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in inheritStateButtonGroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(hObject == handles.inheritStateFromPrevStateRadioBtn)
        handles.inheritStateSpecEvtCombo.Enable = 'off';
    else
        handles.inheritStateSpecEvtCombo.Enable = 'on';
    end


% --- Executes on button press in inheritStageStatesCheckbox.
function inheritStageStatesCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to inheritStageStatesCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of inheritStageStatesCheckbox
    if(not(get(hObject,'Value')))
        
        handles.inheritStageStatesFromPrevStateRadioBtn.Enable = 'off';
        handles.inheritStageStatesFromSpecEvtRadioBtn.Enable = 'off';
        handles.inheritStageStatesSpecEvtCombo.Enable = 'off';
    else
                
        handles.inheritStageStatesFromPrevStateRadioBtn.Enable = 'on';
        handles.inheritStageStatesFromSpecEvtRadioBtn.Enable = 'on';
        inheritStageStatesButtonGroup_SelectionChangedFcn(handles.inheritStageStatesButtonGroup.SelectedObject, [], handles);
    end

% --- Executes on selection change in inheritStageStatesSpecEvtCombo.
function inheritStageStatesSpecEvtCombo_Callback(hObject, eventdata, handles)
% hObject    handle to inheritStageStatesSpecEvtCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns inheritStageStatesSpecEvtCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from inheritStageStatesSpecEvtCombo


% --- Executes during object creation, after setting all properties.
function inheritStageStatesSpecEvtCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inheritStageStatesSpecEvtCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in inheritStageStatesButtonGroup.
function inheritStageStatesButtonGroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in inheritStageStatesButtonGroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(hObject == handles.inheritStageStatesFromPrevStateRadioBtn)
        handles.inheritStageStatesSpecEvtCombo.Enable = 'off';
    else
        handles.inheritStageStatesSpecEvtCombo.Enable = 'on';
    end


% --- Executes on button press in setFrameOptionsButton.
function setFrameOptionsButton_Callback(hObject, eventdata, handles)
% hObject    handle to setFrameOptionsButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    curElemSet = getappdata(handles.lvd_EditActionSetKinematicStateGUI,'curElemSet');
    frame = curElemSet.frame;
    newFrame = frame.editFrameDialogUI(EditReferenceFrameContextEnum.ForState);
    
    updateStateDueToFrameChange(handles, newFrame);


% --- Executes on button press in inheritOtherStateElementsCheckbox.
function inheritOtherStateElementsCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to inheritOtherStateElementsCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of inheritOtherStateElementsCheckbox


% --- Executes on selection change in inheritOtherStateElementsEvtCombo.
function inheritOtherStateElementsEvtCombo_Callback(hObject, eventdata, handles)
% hObject    handle to inheritOtherStateElementsEvtCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns inheritOtherStateElementsEvtCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from inheritOtherStateElementsEvtCombo


% --- Executes during object creation, after setting all properties.
function inheritOtherStateElementsEvtCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inheritOtherStateElementsEvtCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes when selected object is changed in inheritOtherStateElementsButtonGroup.
function inheritOtherStateElementsButtonGroup_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in inheritOtherStateElementsButtonGroup 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if(hObject == handles.inheritOtherStateElementsFromPrevStateRadioBtn)
        handles.inheritOtherStateElementsEvtCombo.Enable = 'off';
    else
        handles.inheritOtherStateElementsEvtCombo.Enable = 'on';
    end
