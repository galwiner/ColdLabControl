function varargout = resultsViewer(varargin)
% RESULTSVIEWER MATLAB code for resultsViewer.fig
%      RESULTSVIEWER, by itself, creates a new RESULTSVIEWER or raises the existing
%      singleton*.
%
%      H = RESULTSVIEWER returns the handle to a new RESULTSVIEWER or the handle to
%      the existing singleton*.
%
%      RESULTSVIEWER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RESULTSVIEWER.M with the given input arguments.
%
%      RESULTSVIEWER('Property','Value',...) creates a new RESULTSVIEWER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before resultsViewer_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to resultsViewer_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help resultsViewer

% Last Modified by GUIDE v2.5 13-Mar-2018 13:05:33

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @resultsViewer_OpeningFcn, ...
                   'gui_OutputFcn',  @resultsViewer_OutputFcn, ...
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


% --- Executes just before resultsViewer is made visible.
function resultsViewer_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to resultsViewer (see VARARGIN)

% Choose default command line output for resultsViewer
handles.output = hObject;
handles.baseDir=GetFullPath(fullfile(fileparts(which(mfilename)),'..','..','..','Measurements'));
% handles.expName=fullfile(handles.baseDir,'2018','02','22','220218_13.mat');



% Update handles structure
guidata(hObject, handles);

% UIWAIT makes resultsViewer wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = resultsViewer_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in selectExpButton.
function selectExpButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectExpButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.expName=experimentBrowser;
handles.experimentSelectText.String=handles.expName;
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on slider movement.
function pfSlider_Callback(hObject, eventdata, handles)
% hObject    handle to pfSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Value = round(get(hObject, 'Value'));
set(hObject, 'Value', Value);
imagesc(handles.pfAxes,handles.r.images{1}(:,:,Value))
if handles.p.postprocessing
    imagesc(handles.FpfAxes,handles.r.fitImages{1}(:,:,Value))
    handles.r.fitParams{1}
    handles.r.GOF{1}.R2
    handles.r.GOF{1}.chi2
    
end

% --- Executes during object creation, after setting all properties.
function pfSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pfSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function tcSlider_Callback(hObject, eventdata, handles)
% hObject    handle to tcSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
Value = round(get(hObject, 'Value'));
set(hObject, 'Value', Value);
if handles.r.ncams==2
imagesc(handles.tcAxes,handles.r.images{2}(:,:,Value))
if handles.p.postprocessing
    if Value<=size(handles.r.fitImages{2},3)
    imagesc(handles.FtcAxes,handles.r.fitImages{2}(:,:,Value))
    end
end
end


% --- Executes during object creation, after setting all properties.
function tcSlider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tcSlider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load(handles.expName);
handles.experimentSelectText.String=handles.expName;
handles.p=p;
handles.r=r;
guidata(hObject, handles);
if handles.p.hasPicturesResults
if handles.r.ncams==0
    return;
elseif ~handles.p.pfLiveMode && handles.p.tcLiveMode
    handles.pfSlider.Enable='on';
    imagesc(handles.pfAxes,handles.r.images{1}(:,:,1))
    handles.pfSlider.Min=1;
    handles.pfSlider.Value=1;
    handles.pfSlider.Max=size(handles.r.images{1},3);
    span=handles.pfSlider.Max-handles.pfSlider.Min;
    if span==0 
        span=1;
    end
    handles.pfSlider.SliderStep=[1/span,0.1];
elseif ~handles.p.tcLiveMode && ~handles.p.pfLiveMode 
    handles.pfSlider.Enable='on';    
    handles.tcSlider.Enable='on';
    imagesc(handles.pfAxes,handles.r.images{1}(:,:,1))
    imagesc(handles.tcAxes,handles.r.images{2}(:,:,1))
    
    handles.pfSlider.Min=1;
    handles.pfSlider.Max=size(handles.r.images{1},3);
    handles.pfSlider.Value=1;
    span=handles.pfSlider.Max-handles.pfSlider.Min;
    if span==0 
        span=1;
    end
    handles.pfSlider.SliderStep=[1/span,0.1];
    handles.tcSlider.Min=1;
    handles.tcSlider.Max=size(handles.r.images{2},3);
    handles.tcSlider.Value=1;
    span=handles.tcSlider.Max-handles.tcSlider.Min;
    if span==0 
        span=1;
    end
    handles.tcSlider.SliderStep=[1/span,0.1];
else
    handles.pfSlider.Enable='off';
    handles.tcSlider.Enable='off';
end

if handles.p.postprocessing

if handles.r.ncams==0
    return;
elseif handles.r.ncams==1
    imagesc(handles.FpfAxes,handles.r.fitImages{1}(:,:,1))
elseif handles.r.ncams==2
    imagesc(handles.FpfAxes,handles.r.fitImages{1}(:,:,1))
    imagesc(handles.FtcAxes,handles.r.fitImages{2}(:,:,1))
end

end    
end
guidata(hObject, handles);
