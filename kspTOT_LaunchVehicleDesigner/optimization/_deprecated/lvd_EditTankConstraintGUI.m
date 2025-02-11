function varargout = lvd_EditTankConstraintGUI(varargin)
% LVD_EDITTANKCONSTRAINTGUI MATLAB code for lvd_EditTankConstraintGUI.fig
%      LVD_EDITTANKCONSTRAINTGUI, by itself, creates a new LVD_EDITTANKCONSTRAINTGUI or raises the existing
%      singleton*.
%
%      H = LVD_EDITTANKCONSTRAINTGUI returns the handle to a new LVD_EDITTANKCONSTRAINTGUI or the handle to
%      the existing singleton*.
%
%      LVD_EDITTANKCONSTRAINTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LVD_EDITTANKCONSTRAINTGUI.M with the given input arguments.
%
%      LVD_EDITTANKCONSTRAINTGUI('Property','Value',...) creates a new LVD_EDITTANKCONSTRAINTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before lvd_EditTankConstraintGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to lvd_EditTankConstraintGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help lvd_EditTankConstraintGUI

% Last Modified by GUIDE v2.5 13-May-2021 10:45:36

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @lvd_EditTankConstraintGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @lvd_EditTankConstraintGUI_OutputFcn, ...
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


% --- Executes just before lvd_EditTankConstraintGUI is made visible.
function lvd_EditTankConstraintGUI_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to lvd_EditTankConstraintGUI (see VARARGIN)

    % Choose default command line output for lvd_EditTankConstraintGUI
    handles.output = hObject;
    
    centerUIFigure(hObject);

    constraint = varargin{1};
    setappdata(hObject, 'constraint', constraint);
    
    lvdData = varargin{2};
    setappdata(hObject,'lvdData',lvdData);
    
	populateGUI(handles, constraint, lvdData);
    
    % Update handles structure
    guidata(hObject, handles);

    % UIWAIT makes lvd_EditTankConstraintGUI wait for user response (see UIRESUME)
    uiwait(handles.lvd_EditGroundObjConstraintGUI);

function populateGUI(handles, constraint, lvdData)
    handles.constraintTypeLabel.String = constraint.getConstraintType();
    handles.constraintTypeLabel.TooltipString = constraint.getConstraintType();
    [unit, ~, ~, usesLbUb, ~, ~] = constraint.getConstraintStaticDetails();
    
    if(usesLbUb)
        [lb, ub] = constraint.getBounds();
        handles.ubText.String = fullAccNum2Str(ub);
        handles.lbText.String = fullAccNum2Str(lb);
    else
        handles.ubText.String = fullAccNum2Str(0);
        handles.lbText.String = fullAccNum2Str(0);
        handles.lbText.Enable = 'off';
        handles.ubText.Enable = 'off';
    end
    
    handles.scaleFactorText.String = fullAccNum2Str(constraint.getScaleFactor());
    
    handles.ubUnitLabel.String = unit;
    handles.lbUnitLabel.String = unit;
    
    evtNum = lvdData.script.getNumOfEvent(constraint.event);
    handles.eventCombo.String = lvdData.script.getListboxStr();
    if(not(isempty(evtNum)))
        handles.eventCombo.Value = evtNum;
    else
        handles.eventCombo.Value = 1;
    end
    
    handles.tankCombo.String = lvdData.launchVehicle.getTanksListBoxStr();
    
    if(isempty(constraint.tank))
        tankInd = 1;
    else
        tankInd = lvdData.launchVehicle.getListBoxIndForTank(constraint.tank);
    end
    handles.tankCombo.Value = tankInd;
        
    handles.constraintEvalTypeCombo.String = ConstraintEvalTypeEnum.getListBoxStr();
    handles.constraintEvalTypeCombo.Value = ConstraintEvalTypeEnum.getIndForName(constraint.evalType.name);
    constraintEvalTypeCombo_Callback(handles.constraintEvalTypeCombo, [], handles);
    
    evtNum = lvdData.script.getNumOfEvent(constraint.stateCompEvent);
    handles.compEventCombo.String = lvdData.script.getListboxStr();
    if(not(isempty(evtNum)))
        handles.compEventCombo.Value = evtNum;
    else
        handles.compEventCombo.Value = 1;
    end
    
    handles.comparisonTypeCombo.String = ConstraintStateComparisonTypeEnum.getListBoxStr();
    handles.comparisonTypeCombo.Value = ConstraintStateComparisonTypeEnum.getIndForName(constraint.stateCompType.name);
    
    handles.stateComparisonNodeCombo.String = ConstraintStateComparisonNodeEnum.getListBoxStr();
    handles.stateComparisonNodeCombo.Value = ConstraintStateComparisonNodeEnum.getIndForName(constraint.stateCompNode.name);
    
    handles.comparisonTypeCombo.String = ConstraintStateComparisonTypeEnum.getListBoxStr();
    handles.comparisonTypeCombo.Value = ConstraintStateComparisonTypeEnum.getIndForName(constraint.stateCompType.name);
    
    handles.constActiveCheckbox.Value = constraint.active;
    
% --- Outputs from this function are returned to the command line.
function varargout = lvd_EditTankConstraintGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
    if(isempty(handles))
        varargout{1} = false;
    else
        constraint = getappdata(hObject, 'constraint');
        lvdData = getappdata(hObject,'lvdData');
        
        constraint.lb = str2double(handles.lbText.String);
        constraint.ub = str2double(handles.ubText.String);
        
        constraint.setScaleFactor(str2double(handles.scaleFactorText.String));
        
        constraint.tank = lvdData.launchVehicle.getTankForInd(handles.tankCombo.Value);
        
        [~, enums] = ConstraintEvalTypeEnum.getListBoxStr();
        constraint.evalType = enums(handles.constraintEvalTypeCombo.Value);
        
        [~, enums] = ConstraintStateComparisonTypeEnum.getListBoxStr();
        constraint.stateCompType = enums(handles.comparisonTypeCombo.Value);
        
        [~, enums] = ConstraintStateComparisonNodeEnum.getListBoxStr();
        constraint.eventNode = enums(handles.eventNodeCombo.Value);
        
        [~, enums] = ConstraintStateComparisonNodeEnum.getListBoxStr();
        constraint.stateCompNode = enums(handles.stateComparisonNodeCombo.Value);
        
        numEvents = lvdData.script.getTotalNumOfEvents();
        if(numEvents > 0)
            eventNum = handles.eventCombo.Value;
            constraint.event = lvdData.script.getEventForInd(eventNum);
            
            if(constraint.evalType == ConstraintEvalTypeEnum.StateComparison)
                eventNum = handles.compEventCombo.Value;
                constraint.stateCompEvent = lvdData.script.getEventForInd(eventNum);
            else
                constraint.stateCompEvent = LaunchVehicleEvent.empty(1,0);
            end
        else
            constraint.event = LaunchVehicleEvent.empty(1,0);
            constraint.stateCompEvent = LaunchVehicleEvent.empty(1,0);
        end
        
        constraint.active = logical(handles.constActiveCheckbox.Value);
        
        varargout{1} = true;
        close(handles.lvd_EditGroundObjConstraintGUI);
    end


% --- Executes on button press in saveAndCloseButton.
function saveAndCloseButton_Callback(hObject, eventdata, handles)
% hObject    handle to saveAndCloseButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    errMsg = validateInputs(handles);
    
    if(isempty(errMsg))
        uiresume(handles.lvd_EditGroundObjConstraintGUI);
    else
        msgbox(errMsg,'Invalid Constraint Inputs','error');
    end


function errMsg = validateInputs(handles)
    errMsg = {};
    
    constraint = getappdata(handles.lvd_EditGroundObjConstraintGUI, 'constraint');
    [~, lbLim, ubLim, usesLbUb, ~, ~] = constraint.getConstraintStaticDetails();
    
    if(usesLbUb)
        lwrBnd = str2double(get(handles.lbText,'String'));
        enteredStr = get(handles.lbText,'String');
        numberName = 'Lower Bound';
        lb = lbLim;
        ub = Inf;
        isInt = false;
        errMsg = validateNumber(lwrBnd, numberName, lb, ub, isInt, errMsg, enteredStr);

        uprBnd = str2double(get(handles.ubText,'String'));
        enteredStr = get(handles.ubText,'String');
        numberName = 'Upper Bound';
        lb = -Inf;
        ub = ubLim;
        isInt = false;
        errMsg = validateNumber(uprBnd, numberName, lb, ub, isInt, errMsg, enteredStr);

        if(isempty(errMsg))
            uprBnd = str2double(get(handles.ubText,'String'));
            enteredStr = get(handles.ubText,'String');
            numberName = 'Upper Bound';
            lb = lwrBnd;
            ub = ubLim;
            isInt = false;
            errMsg = validateNumber(uprBnd, numberName, lb, ub, isInt, errMsg, enteredStr);
        end
    end
    
    sf = str2double(get(handles.scaleFactorText,'String'));
    enteredStr = get(handles.scaleFactorText,'String');
    numberName = 'Scale Factor';
    lb = 1E-12;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(sf, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    [~, enums] = ConstraintEvalTypeEnum.getListBoxStr();
    evalTypeEnum = enums(handles.constraintEvalTypeCombo.Value);
    if(evalTypeEnum == ConstraintEvalTypeEnum.StateComparison && ...
       handles.eventCombo.Value == handles.compEventCombo.Value && ...
       handles.eventNodeCombo.Value == handles.stateComparisonNodeCombo.Value)
        errMsg{end+1} = 'When using the state comparison evaluation type, the Applicable Event and Node and Comparison Event and Node must be different.'; 
    end

    
% --- Executes on button press in cancelButton.
function cancelButton_Callback(hObject, eventdata, handles)
% hObject    handle to cancelButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    close(handles.lvd_EditGroundObjConstraintGUI);


function lbText_Callback(hObject, eventdata, handles)
% hObject    handle to lbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of lbText as text
%        str2double(get(hObject,'String')) returns contents of lbText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function lbText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function constraintTypeLabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to constraintTypeLabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function ubText_Callback(hObject, eventdata, handles)
% hObject    handle to ubText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ubText as text
%        str2double(get(hObject,'String')) returns contents of ubText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function ubText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ubText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in tankCombo.
function tankCombo_Callback(hObject, eventdata, handles)
% hObject    handle to tankCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns tankCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from tankCombo


% --- Executes during object creation, after setting all properties.
function tankCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tankCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in eventCombo.
function eventCombo_Callback(hObject, eventdata, handles)
% hObject    handle to eventCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns eventCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from eventCombo


% --- Executes during object creation, after setting all properties.
function eventCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function scaleFactorText_Callback(hObject, eventdata, handles)
% hObject    handle to scaleFactorText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of scaleFactorText as text
%        str2double(get(hObject,'String')) returns contents of scaleFactorText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function scaleFactorText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to scaleFactorText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on key press with focus on lvd_EditTankConstraintGUI or any of its controls.
function lvd_EditGroundObjConstraintGUI_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to lvd_EditTankConstraintGUI (see GCBO)
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
            close(handles.lvd_EditGroundObjConstraintGUI);
    end


% --- Executes on button press in constActiveCheckbox.
function constActiveCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to constActiveCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of constActiveCheckbox


% --- Executes on selection change in constraintEvalTypeCombo.
function constraintEvalTypeCombo_Callback(hObject, eventdata, handles)
% hObject    handle to constraintEvalTypeCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns constraintEvalTypeCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from constraintEvalTypeCombo
    contents = cellstr(get(hObject,'String'));
    name = contents{get(hObject,'Value')};

    enum = ConstraintEvalTypeEnum.getEnumForListboxStr(name);
    switch enum
        case ConstraintEvalTypeEnum.FixedBounds
            handles.ubText.Enable = 'on';
            handles.lbText.Enable = 'on';
            handles.compEventCombo.Enable = 'off';
            handles.comparisonTypeCombo.Enable = 'off';
            handles.stateComparisonNodeCombo.Enable = 'off';
            
        case ConstraintEvalTypeEnum.StateComparison
            handles.ubText.Enable = 'off';
            handles.lbText.Enable = 'off';
            handles.compEventCombo.Enable = 'on';
            handles.comparisonTypeCombo.Enable = 'on';
            handles.stateComparisonNodeCombo.Enable = 'on';
            
        otherwise
            error('Unknown constraint evaluation type.');
    end

% --- Executes during object creation, after setting all properties.
function constraintEvalTypeCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to constraintEvalTypeCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in compEventCombo.
function compEventCombo_Callback(hObject, eventdata, handles)
% hObject    handle to compEventCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns compEventCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from compEventCombo


% --- Executes during object creation, after setting all properties.
function compEventCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to compEventCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in comparisonTypeCombo.
function comparisonTypeCombo_Callback(hObject, eventdata, handles)
% hObject    handle to comparisonTypeCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns comparisonTypeCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from comparisonTypeCombo


% --- Executes during object creation, after setting all properties.
function comparisonTypeCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to comparisonTypeCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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



% --- Executes on selection change in eventNodeCombo.
function eventNodeCombo_Callback(hObject, eventdata, handles)
% hObject    handle to eventNodeCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns eventNodeCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from eventNodeCombo


% --- Executes during object creation, after setting all properties.
function eventNodeCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eventNodeCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in stateComparisonNodeCombo.
function stateComparisonNodeCombo_Callback(hObject, eventdata, handles)
% hObject    handle to stateComparisonNodeCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns stateComparisonNodeCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from stateComparisonNodeCombo


% --- Executes during object creation, after setting all properties.
function stateComparisonNodeCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stateComparisonNodeCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
