function varargout = ma_AstroCalculatorsGUI(varargin)
% ma_AstroCalulatorGUI MATLAB code for ma_AstroCalulatorGUI.fig
%      ma_AstroCalulatorGUI, by itself, creates a new ma_AstroCalulatorGUI or raises the existing
%      singleton*.
%
%      H = ma_AstroCalulatorGUI returns the handle to a new ma_AstroCalulatorGUI or the handle to
%      the existing singleton*.
%
%      ma_AstroCalulatorGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ma_AstroCalulatorGUI.M with the given input arguments.
%
%      ma_AstroCalulatorGUI('Property','Value',...) creates a new ma_AstroCalulatorGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ma_AstroCalulatorGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ma_AstroCalulatorGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ma_AstroCalulatorGUI

% Last Modified by GUIDE v2.5 11-Dec-2020 13:26:37

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ma_AstroCalulatorGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @ma_AstroCalulatorGUI_OutputFcn, ...
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


% --- Executes just before ma_AstroCalulatorGUI is made visible.
function ma_AstroCalulatorGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ma_AstroCalulatorGUI (see VARARGIN)

% Choose default command line output for ma_AstroCalulatorGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

celBodyData = varargin{1};
setappdata(hObject,'celBodyData',celBodyData);

guidata(hObject, handles);

setUpGui(handles);

% UIWAIT makes ma_AstroCalulatorGUI wait for user response (see UIRESUME)
% uiwait(handles.ma_AstroCalulatorGUI);

function setUpGui(handles)
    celBodyData = getappdata(handles.ma_AstroCalulatorGUI,'celBodyData');
    populateBodiesCombo(celBodyData, handles.centralBodyCombo);



% --- Outputs from this function are returned to the command line.
function varargout = ma_AstroCalulatorGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in centralBodyCombo.
function centralBodyCombo_Callback(hObject, eventdata, handles)
% hObject    handle to centralBodyCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns centralBodyCombo contents as cell array
%        contents{get(hObject,'Value')} returns selected item from centralBodyCombo


% --- Executes during object creation, after setting all properties.
function centralBodyCombo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to centralBodyCombo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function smaFromRpRaText_Callback(hObject, eventdata, handles)
% hObject    handle to smaFromRpRaText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smaFromRpRaText as text
%        str2double(get(hObject,'String')) returns contents of smaFromRpRaText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function smaFromRpRaText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smaFromRpRaText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in computeSmaEccFromRaRpButton.
function computeSmaEccFromRaRpButton_Callback(hObject, eventdata, handles)
% hObject    handle to computeSmaEccFromRaRpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    errMsg = {};

    value = str2double(get(handles.RaFromSmaEccText,'String'));
    enteredStr = get(handles.RaFromSmaEccText,'String');
    numberName = 'Radius of Apoapsis';
    lb = -Inf;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(value, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    value = str2double(get(handles.RpFromSmaEccText,'String'));
    enteredStr = get(handles.RpFromSmaEccText,'String');
    numberName = 'Radius of Periapsis';
    lb = 0.001;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(value, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    if(isempty(errMsg))        
        rA = str2double(get(handles.RaFromSmaEccText,'String'));
        rP = str2double(get(handles.RpFromSmaEccText,'String'));
        
        [sma, ecc] =  computeSmaEccFromRaRp(rA, rP);
        set(handles.smaFromRpRaText,'String',sprintf('%0.5f',sma));
        set(handles.eccFromRpRaText,'String',sprintf('%0.8f',ecc));
    else
        msgbox(errMsg,'Errors were found computing SMA.','error');
    end

% --- Executes on button press in computeRaRpFromSmaEccButton.
function computeRaRpFromSmaEccButton_Callback(hObject, eventdata, handles)
% hObject    handle to computeRaRpFromSmaEccButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    errMsg = {};
    
    eccValue = str2double(get(handles.eccFromRpRaText,'String'));
    enteredStr = get(handles.eccFromRpRaText,'String');
    numberName = 'Radius of Periapsis';
    lb = 0;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(eccValue, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    if(eccValue < 1)
        value = str2double(get(handles.smaFromRpRaText,'String'));
        enteredStr = get(handles.smaFromRpRaText,'String');
        numberName = 'Semi-major Axis';
        lb = 0.001;
        ub = Inf;
        isInt = false;
        errMsg = validateNumber(value, numberName, lb, ub, isInt, errMsg, enteredStr);
    else
        value = str2double(get(handles.smaFromRpRaText,'String'));
        enteredStr = get(handles.smaFromRpRaText,'String');
        numberName = 'Semi-major Axis';
        lb = -Inf;
        ub = -0.001;
        isInt = false;
        errMsg = validateNumber(value, numberName, lb, ub, isInt, errMsg, enteredStr);
    end
    
    if(isempty(errMsg))        
        sma = str2double(get(handles.smaFromRpRaText,'String'));
        ecc = str2double(get(handles.eccFromRpRaText,'String'));

        [rAp, rPe] = computeApogeePerigee(sma, ecc);
        set(handles.RaFromSmaEccText,'String',sprintf('%0.5f',rAp));
        set(handles.RpFromSmaEccText,'String',sprintf('%0.5f',rPe));
    else
        msgbox(errMsg,'Errors were found computing SMA.','error');
    end


function RaFromSmaEccText_Callback(hObject, eventdata, handles)
% hObject    handle to RaFromSmaEccText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RaFromSmaEccText as text
%        str2double(get(hObject,'String')) returns contents of RaFromSmaEccText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function RaFromSmaEccText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RaFromSmaEccText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eccFromRpRaText_Callback(hObject, eventdata, handles)
% hObject    handle to eccFromRpRaText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eccFromRpRaText as text
%        str2double(get(hObject,'String')) returns contents of eccFromRpRaText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function eccFromRpRaText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eccFromRpRaText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function RpFromSmaEccText_Callback(hObject, eventdata, handles)
% hObject    handle to RpFromSmaEccText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of RpFromSmaEccText as text
%        str2double(get(hObject,'String')) returns contents of RpFromSmaEccText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function RpFromSmaEccText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RpFromSmaEccText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function smaPeriodText_Callback(hObject, eventdata, handles)
% hObject    handle to smaPeriodText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smaPeriodText as text
%        str2double(get(hObject,'String')) returns contents of smaPeriodText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function smaPeriodText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smaPeriodText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in computeSmaFromPeriodButton.
function computeSmaFromPeriodButton_Callback(hObject, eventdata, handles)
% hObject    handle to computeSmaFromPeriodButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    errMsg = {};

    value = str2double(get(handles.periodSmaText,'String'));
    enteredStr = get(handles.periodSmaText,'String');
    numberName = 'Orbital Period';
    lb = 0.001;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(value, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    if(isempty(errMsg))
        celBodyData = getappdata(handles.ma_AstroCalulatorGUI,'celBodyData');
        contents = cellstr(get(handles.centralBodyCombo,'String'));
        sel = strtrim(lower(contents{get(handles.centralBodyCombo,'Value')}));
        bodyInfo = celBodyData.(sel);
        
        period = str2double(get(handles.periodSmaText,'String'));
        gmu = bodyInfo.gm;
        
        sma = computeSMAFromPeriod(period, gmu);
        set(handles.smaPeriodText,'String',sprintf('%0.5f',sma));
    else
        msgbox(errMsg,'Errors were found computing SMA.','error');
    end

% --- Executes on button press in computePeriodFromSmaButton.
function computePeriodFromSmaButton_Callback(hObject, eventdata, handles)
% hObject    handle to computePeriodFromSmaButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    errMsg = {};

    value = str2double(get(handles.smaPeriodText,'String'));
    enteredStr = get(handles.smaPeriodText,'String');
    numberName = 'Semi-major Axis';
    lb = 0.001;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(value, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    if(isempty(errMsg))
        celBodyData = getappdata(handles.ma_AstroCalulatorGUI,'celBodyData');
        contents = cellstr(get(handles.centralBodyCombo,'String'));
        sel = strtrim(lower(contents{get(handles.centralBodyCombo,'Value')}));
        bodyInfo = celBodyData.(sel);
        
        sma = str2double(get(handles.smaPeriodText,'String'));
        gmu = bodyInfo.gm;
        
        sma = computePeriod(sma, gmu);
        set(handles.periodSmaText,'String',sprintf('%0.5f',sma));
    else
        msgbox(errMsg,'Errors were found computing SMA.','error');
    end


function periodSmaText_Callback(hObject, eventdata, handles)
% hObject    handle to periodSmaText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of periodSmaText as text
%        str2double(get(hObject,'String')) returns contents of periodSmaText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function periodSmaText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to periodSmaText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in computeTrueAnomalyFromLongButton.
function computeTrueAnomalyFromLongButton_Callback(hObject, eventdata, handles)
% hObject    handle to computeTrueAnomalyFromLongButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    errMsg = {};

    value = str2double(get(handles.epochTrueAnomText,'String'));
    enteredStr = get(handles.epochTrueAnomText,'String');
    numberName = 'Epoch of True Anomaly';
    lb = -Inf;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(value, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    value = str2double(get(handles.longFromTrueAnomText,'String'));
    enteredStr = get(handles.longFromTrueAnomText,'String');
    numberName = 'Longitude';
    lb = -360;
    ub = 360;
    isInt = false;
    errMsg = validateNumber(value, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    if(isempty(errMsg))
        celBodyData = getappdata(handles.ma_AstroCalulatorGUI,'celBodyData');
        contents = cellstr(get(handles.centralBodyCombo,'String'));
        sel = strtrim(lower(contents{get(handles.centralBodyCombo,'Value')}));
        bodyInfo = celBodyData.(sel);
        
        ut = str2double(get(handles.epochTrueAnomText,'String'));
        long = deg2rad(str2double(get(handles.longFromTrueAnomText,'String')));
        syncSMA = computeSMAFromPeriod(bodyInfo.rotperiod, bodyInfo.gm);
        rVectECI = getInertialVectFromLatLongAlt(ut, 0.0, long, syncSMA, bodyInfo, [NaN;NaN;NaN]);
        tru = dang(rVectECI,[1;0;0]);
        if(rVectECI(2) < 0)
            tru = 2*pi - tru;
        end
        tru = rad2deg(tru);
        
        set(handles.trueAnomFromLongText,'String',sprintf('%0.5f',tru));
    else
        msgbox(errMsg,'Errors were found computing SMA.','error');
    end

% --- Executes on button press in computeLongFromTrueAnomButton.
function computeLongFromTrueAnomButton_Callback(hObject, eventdata, handles)
% hObject    handle to computeLongFromTrueAnomButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    errMsg = {};

    value = str2double(get(handles.epochTrueAnomText,'String'));
    enteredStr = get(handles.epochTrueAnomText,'String');
    numberName = 'Epoch of True Anomaly';
    lb = -Inf;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(value, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    value = str2double(get(handles.trueAnomFromLongText,'String'));
    enteredStr = get(handles.trueAnomFromLongText,'String');
    numberName = 'True Anomay';
    lb = -360;
    ub = 360;
    isInt = false;
    errMsg = validateNumber(value, numberName, lb, ub, isInt, errMsg, enteredStr);

    if(isempty(errMsg))
        celBodyData = getappdata(handles.ma_AstroCalulatorGUI,'celBodyData');
        contents = cellstr(get(handles.centralBodyCombo,'String'));
        sel = strtrim(lower(contents{get(handles.centralBodyCombo,'Value')}));
        bodyInfo = celBodyData.(sel);
        
        ut = str2double(get(handles.epochTrueAnomText,'String'));
        tru = deg2rad(str2double(get(handles.trueAnomFromLongText,'String')));
        syncSMA = computeSMAFromPeriod(bodyInfo.rotperiod, bodyInfo.gm);
        [rVectECI,vVectECI]=getStatefromKepler(syncSMA, 0.0, 0.0, 0.0, 0.0, tru, bodyInfo.gm, true);
        [~, long, ~] = getLatLongAltFromInertialVect(ut, rVectECI, bodyInfo, vVectECI);
        long = rad2deg(long);
        
        set(handles.longFromTrueAnomText,'String',sprintf('%0.5f',long));
    else
        msgbox(errMsg,'Errors were found computing SMA.','error');
    end

function epochTrueAnomText_Callback(hObject, eventdata, handles)
% hObject    handle to epochTrueAnomText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epochTrueAnomText as text
%        str2double(get(hObject,'String')) returns contents of epochTrueAnomText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function epochTrueAnomText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epochTrueAnomText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function trueAnomFromLongText_Callback(hObject, eventdata, handles)
% hObject    handle to trueAnomFromLongText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of trueAnomFromLongText as text
%        str2double(get(hObject,'String')) returns contents of trueAnomFromLongText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function trueAnomFromLongText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to trueAnomFromLongText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function longFromTrueAnomText_Callback(hObject, eventdata, handles)
% hObject    handle to longFromTrueAnomText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of longFromTrueAnomText as text
%        str2double(get(hObject,'String')) returns contents of longFromTrueAnomText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function longFromTrueAnomText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to longFromTrueAnomText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in computeSmaEccTruButton.
function computeSmaEccTruButton_Callback(hObject, eventdata, handles)
% hObject    handle to computeSmaEccTruButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    errMsg = {};

    radius = str2double(get(handles.rSmaEccTruText,'String'));
    enteredStr = get(handles.rSmaEccTruText,'String');
    numberName = 'Spacecraft Radius';
    lb = 0.001;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(radius, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    velocity = str2double(get(handles.vSmaEccTruText,'String'));
    enteredStr = get(handles.vSmaEccTruText,'String');
    numberName = 'Spacecraft Velocity';
    lb = 0.001;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(velocity, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    fpa = str2double(get(handles.fpaSmaEccTruText,'String'));
    enteredStr = get(handles.fpaSmaEccTruText,'String');
    numberName = 'True Anomay';
    lb = -90;
    ub = 90;
    isInt = false;
    errMsg = validateNumber(fpa, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    if(isempty(errMsg))
        celBodyData = getappdata(handles.ma_AstroCalulatorGUI,'celBodyData');
        contents = cellstr(get(handles.centralBodyCombo,'String'));
        sel = strtrim(lower(contents{get(handles.centralBodyCombo,'Value')}));
        bodyInfo = celBodyData.(sel);
        
        fpa = deg2rad(fpa);
        
        [sma, ecc, tru] = computeSmaEccTruFromRVFpa(radius, velocity, fpa, bodyInfo.gm);
        
        handles.smaRVPathText.String = fullAccNum2Str(sma);
        handles.eccRVPathText.String = fullAccNum2Str(ecc);
        handles.truRVPathText.String = fullAccNum2Str(rad2deg(tru));
    else
        msgbox(errMsg,'Errors were found computing SMA/Ecc/True Anomaly.','error');
    end




% --- Executes on button press in computeRVFpaButton.
function computeRVFpaButton_Callback(hObject, eventdata, handles)
% hObject    handle to computeRVFpaButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    errMsg = {};

    ecc = str2double(get(handles.eccRVPathText,'String'));
    enteredStr = get(handles.eccRVPathText,'String');
    numberName = 'Eccentricity';
    lb = 0;
    ub = Inf;
    isInt = false;
    errMsg = validateNumber(ecc, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    if(ecc < 1)
        sma = str2double(get(handles.smaRVPathText,'String'));
        enteredStr = get(handles.smaRVPathText,'String');
        numberName = 'Semi-major Axis';
        lb = 0.001;
        ub = Inf;
        isInt = false;
        errMsg = validateNumber(sma, numberName, lb, ub, isInt, errMsg, enteredStr);
    else
        sma = str2double(get(handles.smaRVPathText,'String'));
        enteredStr = get(handles.smaRVPathText,'String');
        numberName = 'Semi-major Axis';
        lb = -Inf;
        ub = -0.001;
        isInt = false;
        errMsg = validateNumber(sma, numberName, lb, ub, isInt, errMsg, enteredStr);
    end
    
    tru = str2double(get(handles.truRVPathText,'String'));
    enteredStr = get(handles.truRVPathText,'String');
    numberName = 'True Anomay';
    lb = -360;
    ub = 360;
    isInt = false;
    errMsg = validateNumber(tru, numberName, lb, ub, isInt, errMsg, enteredStr);
    
    if(isempty(errMsg))
        celBodyData = getappdata(handles.ma_AstroCalulatorGUI,'celBodyData');
        contents = cellstr(get(handles.centralBodyCombo,'String'));
        sel = strtrim(lower(contents{get(handles.centralBodyCombo,'Value')}));
        bodyInfo = celBodyData.(sel);
        
        tru = deg2rad(tru);
        
        [radius, velocity, fpa] = computeRVFpaFromSmaEccTru(sma, ecc, tru, bodyInfo.gm);
        
        handles.rSmaEccTruText.String = fullAccNum2Str(radius);
        handles.vSmaEccTruText.String = fullAccNum2Str(velocity);
        handles.fpaSmaEccTruText.String = fullAccNum2Str(rad2deg(fpa));
    else
        msgbox(errMsg,'Errors were found computing R/V/FPA.','error');
    end


function smaRVPathText_Callback(hObject, eventdata, handles)
% hObject    handle to smaRVPathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of smaRVPathText as text
%        str2double(get(hObject,'String')) returns contents of smaRVPathText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function smaRVPathText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to smaRVPathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eccRVPathText_Callback(hObject, eventdata, handles)
% hObject    handle to eccRVPathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eccRVPathText as text
%        str2double(get(hObject,'String')) returns contents of eccRVPathText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function eccRVPathText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eccRVPathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function truRVPathText_Callback(hObject, eventdata, handles)
% hObject    handle to truRVPathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of truRVPathText as text
%        str2double(get(hObject,'String')) returns contents of truRVPathText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function truRVPathText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to truRVPathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function rSmaEccTruText_Callback(hObject, eventdata, handles)
% hObject    handle to rSmaEccTruText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rSmaEccTruText as text
%        str2double(get(hObject,'String')) returns contents of rSmaEccTruText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function rSmaEccTruText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to rSmaEccTruText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function vSmaEccTruText_Callback(hObject, eventdata, handles)
% hObject    handle to vSmaEccTruText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of vSmaEccTruText as text
%        str2double(get(hObject,'String')) returns contents of vSmaEccTruText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function vSmaEccTruText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to vSmaEccTruText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function fpaSmaEccTruText_Callback(hObject, eventdata, handles)
% hObject    handle to fpaSmaEccTruText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of fpaSmaEccTruText as text
%        str2double(get(hObject,'String')) returns contents of fpaSmaEccTruText as a double
    newInput = get(hObject,'String');
    newInput = attemptStrEval(newInput);
    set(hObject,'String', newInput);

% --- Executes during object creation, after setting all properties.
function fpaSmaEccTruText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fpaSmaEccTruText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
