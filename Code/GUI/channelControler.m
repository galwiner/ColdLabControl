function varargout = channelControler(varargin)
% CHANNELCONTROLER MATLAB code for channelControler.fig
%      CHANNELCONTROLER, by itself, creates a new CHANNELCONTROLER or raises the existing
%      singleton*.
%
%      H = CHANNELCONTROLER returns the handle to a new CHANNELCONTROLER or the handle to
%      the existing singleton*.
%
%      CHANNELCONTROLER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHANNELCONTROLER.M with the given input arguments.
%
%      CHANNELCONTROLER('Property','Value',...) creates a new CHANNELCONTROLER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before channelControler_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to channelControler_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help channelControler

% Last Modified by GUIDE v2.5 18-Mar-2018 17:05:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @channelControler_OpeningFcn, ...
                   'gui_OutputFcn',  @channelControler_OutputFcn, ...
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


% --- Executes just before channelControler is made visible.
function channelControler_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to channelControler (see VARARGIN)

% Choose default command line output for channelControler
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes channelControler wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = channelControler_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in DIO1.
function DIO1_Callback(hObject, eventdata, handles)
% hObject    handle to DIO1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

updateDigital('DigOut1',get(hObject,'Value'),handles)

% Hint: get(hObject,'Value') returns toggle state of DIO1

% if get(hObject,'Value')
%     val=0;
% else 
%     val=-1;
% end
% 
% % handles.statusText.String=num2str(get(hObject,'Value'));
% prog=CodeGenerator();
% prog.GenSeq({Pulse('DigOut1',0,val)});
% prog.GenFinish;
% try
%     handles.com.UploadCode(prog);
%     handles.com.UpdateFpga;
%     handles.com.WaitForHostIdle;
%     handles.com.Execute(1);
% catch err
%     error('error');
% end
% handles.statusText.String=sprintf('Completed channel 1 update: val=%d',val);

function updateDigital(chan,val,handles)
if val
    val=0;
else 
    val=-1;
end

prog=CodeGenerator();
prog.GenSeq({Pulse(chan,0,val)});
prog.GenFinish;
try
    handles.com.UploadCode(prog);
    handles.com.UpdateFpga;
    handles.com.WaitForHostIdle;
    handles.com.Execute(1);
catch err
    error('error');
end
handles.statusText.String=sprintf('Completed channel %s update: val=%d',chan,val);

    
    


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4


% --- Executes on button press in checkbox5.
function checkbox5_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox5


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
handles.s=sqncr();
guidata(hObject, handles);


% --- Executes on button press in connButton.
function connButton_Callback(hObject, eventdata, handles)
% hObject    handle to connButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.com=Tcp2Labview('localhost',6340);
handles.statusText.String=sprintf('FPGA connection status: %s',handles.com.TcpID.Status);


handles.DIO0.Enable='on';
handles.DIO1.Enable='on';
handles.DIO8.Enable='on';
handles.DIO9.Enable='on';

guidata(hObject, handles);



function statusText_Callback(hObject, eventdata, handles)
% hObject    handle to statusText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of statusText as text
%        str2double(get(hObject,'String')) returns contents of statusText as a double


% --- Executes during object creation, after setting all properties.
function statusText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to statusText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DIO0.
function DIO0_Callback(hObject, eventdata, handles)
% hObject    handle to DIO0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateDigital('DigOut0',get(hObject,'Value'),handles)
% Hint: get(hObject,'Value') returns toggle state of DIO0


% --- Executes on button press in DIO8.
function DIO8_Callback(hObject, eventdata, handles)
% hObject    handle to DIO8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateDigital('DigOut8',get(hObject,'Value'),handles)
% Hint: get(hObject,'Value') returns toggle state of DIO8


% --- Executes on button press in DIO9.
function DIO9_Callback(hObject, eventdata, handles)
% hObject    handle to DIO9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
updateDigital('DigOut9',get(hObject,'Value'),handles)
% Hint: get(hObject,'Value') returns toggle state of DIO9


% --- Executes on button press in shuButton.
function shuButton_Callback(hObject, eventdata, handles)
% hObject    handle to shuButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in shuExtClockButton.
function shuExtClockButton_Callback(hObject, eventdata, handles)
% hObject    handle to shuExtClockButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in shuExtClock.
function shuExtClock_Callback(hObject, eventdata, handles)
% hObject    handle to shuExtClock (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shuExtClock
stat=get(hObject,'Value');
Rubidium_CLOCK_2017(stat)
handles.statusText.String=sprintf('DDS Ext Clock status: %d',stat);

function freqChan1text_Callback(hObject, eventdata, handles)
% hObject    handle to freqChan1text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freqChan1text as text
%        str2double(get(hObject,'String')) returns contents of freqChan1text as a double


% --- Executes during object creation, after setting all properties.
function freqChan1text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqChan1text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in shu1ExtClk.
function shu1ExtClk_Callback(hObject, eventdata, handles)
% hObject    handle to shu1ExtClk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shu1ExtClk


% --- Executes on button press in shu1Button.
function shu1Button_Callback(hObject, eventdata, handles)
% hObject    handle to shu1Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
profile0_A(str2double(handles.freqChan1text.String),0,0);
handles.statusText.String=sprintf('Set chan1 freq to %f',str2double(handles.freqChan1text.String));

% --- Executes on button press in initChan1Button.
function initChan1Button_Callback(hObject, eventdata, handles)
% hObject    handle to initChan1Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SHU1_initial_2016(0,1,1);
handles.shu1Button.Enable='on';
handles.shu1ExtClk.Enable='on';
handles.freqChan1text.Enable='on';
handles.statusText.String='Enabled DDS chan 1';



function freqChan2text_Callback(hObject, eventdata, handles)
% hObject    handle to freqChan2text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freqChan2text as text
%        str2double(get(hObject,'String')) returns contents of freqChan2text as a double


% --- Executes during object creation, after setting all properties.
function freqChan2text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqChan2text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in shu2ExtClk.
function shu2ExtClk_Callback(hObject, eventdata, handles)
% hObject    handle to shu2ExtClk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of shu2ExtClk


% --- Executes on button press in shu2Button.
function shu2Button_Callback(hObject, eventdata, handles)
% hObject    handle to shu2Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
profile0_B(str2double(handles.freqChan2text.String),0,0);
handles.statusText.String=sprintf('Set chan2 freq to %f',str2double(handles.freqChan2text.String));

% --- Executes on button press in initChan2Button.
function initChan2Button_Callback(hObject, eventdata, handles)
% hObject    handle to initChan3Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SHU2_initial_2016(0,1,1);
handles.shu2Button.Enable='on';
handles.shu2ExtClk.Enable='on';
handles.freqChan2text.Enable='on';
handles.statusText.String='Enabled DDS chan 2';

% --- Executes on button press in initChan3Button.
function initChan3Button_Callback(hObject, eventdata, handles)
% hObject    handle to initChan3Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SHU3_initial_2016(0,1,1);
handles.shu3Button.Enable='on';
handles.shu3ExtClk.Enable='on';
handles.freqChan3text.Enable='on';
handles.statusText.String='Enabled DDS chan 3';


function freqChan3text_Callback(hObject, eventdata, handles)
% hObject    handle to freqChan3text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freqChan3text as text
%        str2double(get(hObject,'String')) returns contents of freqChan3text as a double


% --- Executes during object creation, after setting all properties.
function freqChan3text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqChan3text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox12.
function checkbox12_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox12


% --- Executes on button press in shu3Button.
function shu3Button_Callback(hObject, eventdata, handles)
% hObject    handle to shu3Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
profile0_C(str2double(handles.freqChan3text.String),0,0);
handles.statusText.String=sprintf('Set chan3 freq to %f',str2double(handles.freqChan3text.String));



% --- Executes on button press in initChan3Button.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to initChan3Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function freqChan4text_Callback(hObject, eventdata, handles)
% hObject    handle to freqChan4text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of freqChan4text as text
%        str2double(get(hObject,'String')) returns contents of freqChan4text as a double


% --- Executes during object creation, after setting all properties.
function freqChan4text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to freqChan4text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox13.
function checkbox13_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox13


% --- Executes on button press in shu4Button.
function shu4Button_Callback(hObject, eventdata, handles)
% hObject    handle to shu4Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
profile0_D(str2double(handles.freqChan4text.String),0,0);
handles.statusText.String=sprintf('Set chan4 freq to %f',str2double(handles.freqChan4text.String));


% --- Executes on button press in initChan4Button.
function initChan4Button_Callback(hObject, eventdata, handles)
% hObject    handle to initChan4Button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SHU4_initial_2016(0,1,1);
handles.shu4Button.Enable='on';
handles.shu4ExtClk.Enable='on';
handles.freqChan4text.Enable='on';
handles.statusText.String='Enabled DDS chan 4';

% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
