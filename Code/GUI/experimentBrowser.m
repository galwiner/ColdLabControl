function varargout = experimentBrowser(varargin)
% EXPERIMENTBROWSER MATLAB code for experimentBrowser.fig
%      EXPERIMENTBROWSER, by itself, creates a new EXPERIMENTBROWSER or raises the existing
%      singleton*.
%
%      H = EXPERIMENTBROWSER returns the handle to a new EXPERIMENTBROWSER or the handle to
%      the existing singleton*.
%
%      EXPERIMENTBROWSER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXPERIMENTBROWSER.M with the given input arguments.
%
%      EXPERIMENTBROWSER('Property','Value',...) creates a new EXPERIMENTBROWSER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before experimentBrowser_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to experimentBrowser_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help experimentBrowser

% Last Modified by GUIDE v2.5 22-Mar-2018 15:03:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @experimentBrowser_OpeningFcn, ...
                   'gui_OutputFcn',  @experimentBrowser_OutputFcn, ...
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


% --- Executes just before experimentBrowser is made visible.
function experimentBrowser_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to experimentBrowser (see VARARGIN)

% Choose default command line output for experimentBrowser
handles.output = hObject;
% setenv('MW_MINGW64_LOC','c:\TDM-GCC-64') try this if mex doesn't work for
% GetFullPath
handles.baseDir=GetFullPath(fullfile(fileparts(which(mfilename)),'..','..','..','Measurements'));
handles.currDir=handles.baseDir;
handles.currDirText.String=GetFullPath(handles.currDir);
dirName=dir(handles.currDir);
handles.fileList.String=({dirName.name});

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes experimentBrowser wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = experimentBrowser_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.expFile;
delete(handles.figure1);


% --- Executes on selection change in fileList.
function fileList_Callback(hObject, eventdata, handles)
% hObject    handle to fileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns fileList contents as cell array
%        contents{get(hObject,'Value')} returns selected item from fileList
contents = cellstr(get(hObject,'String'));
selection=contents{get(hObject,'Value')};
selection = regexprep(selection, '<.*?>', '' ) ;
if regexp(selection,'^[\w,\s-]+\.[A-Za-z]{1,}$','match','once') %if it's a file name, step inside
    if regexp(selection,'^[\w,\s-]+\.mat$','match','once') % if it's a .mat file, step inside
        handles.expFile=fullfile(handles.currDir,selection);
        S=load(handles.expFile);
        guidata(hObject, handles);
        if isfield(S,'p') && isfield(S,'r')
            %         a=fileread(fullfile(handles.currDir,selection));
            handles.contentsBox.String=sprintf('%s: Valid experiment file!',selection);
            handles.loadButton.Enable='on';
            handles.sqncText.String=S.p.s.stringify;
            if isstruct(S.r)
                handles.ResultsView.String=values(S.r);
            else
                handles.ResultsView.String='No results';
            end
            
            handles.pTable.RowName=fields(S.p);
            fieldNames = fieldnames(S.p);
            vals=cell(length(fieldNames),1);
            for ind=1:length(fieldNames)
            if isnumeric(S.p.(fieldNames{ind}))
                entry=num2str(S.p.(fieldNames{ind}));
            else
                entry='';
            end
            if length(entry)>1
                entry=[entry];
            end
            if isempty(entry)
                entry='';
            end
                vals{ind} = entry;

            end
            handles.pTable.Data=vals;
            return;
        else
            handles.contentsBox.String=sprintf('%s: Not a valid experiment file!',selection);
            handles.sqncText.String='';
            handles.pTable.Data='';
            handles.loadButton.Enable='off';
            return;
        end
    end
            handles.contentsBox.String=sprintf('%s: Not a valid experiment file!',selection);
            handles.sqncText.String='';
            handles.pTable.Data='';
            handles.loadButton.Enable='off';
            return;
end

handles.currDir=GetFullPath(fullfile(handles.currDir,selection));
handles.currDirText.String=handles.currDir;
dirName=dir(handles.currDir);
listing={dirName.name};
if ~isempty(listing)
    for ind=1:length(listing)
        res=regexp(listing(ind),'^[\w,\s-]+\.mat$','match','once');
           if(~isempty(res{1}))
               S=load(fullfile(handles.currDir,listing{ind}));
               if isfield(S,'p')
               if S.p.hasPicturesResults
                listing{ind}=sprintf('<HTML><BODY bgcolor="%s">%s', 'green', listing{ind});
               else
                listing{ind}=sprintf('<HTML><BODY bgcolor="%s">%s', 'red', listing{ind});
               end
               else
                   listing{ind}=sprintf('<HTML><BODY bgcolor="%s">%s', 'white', listing{ind});
               end
               
%                if isfield(S,'r')
%                 handles.
%                end
               
           end
               
        
    end
    handles.fileList.String=(listing);
    handles.fileList.Value=1;
end
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function fileList_CreateFcn(hObject, eventdata, handles)
% hObject    handle to fileList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in homeButton.
function homeButton_Callback(hObject, eventdata, handles)
% hObject    handle to homeButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currDir=handles.baseDir;
dirName=dir(handles.currDir);
handles.currDirText.String=handles.currDir;
handles.sqncText.String='';
handles.pTable.Data='';
listing={dirName.name};
handles.fileList.String=(listing);
guidata(hObject, handles);



function contentsBox_Callback(hObject, eventdata, handles)
% hObject    handle to contentsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of contentsBox as text
%        str2double(get(hObject,'String')) returns contents of contentsBox as a double


% --- Executes during object creation, after setting all properties.
function contentsBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to contentsBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in nowButton.
function nowButton_Callback(hObject, eventdata, handles)
% hObject    handle to nowButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.currDir=handles.baseDir;
handles.currDir=fullfile(handles.currDir,num2str(year(now())),sprintf('%02d',month(now())));
handles.currDirText.String=GetFullPath(handles.currDir);
handles.sqncText.String='';
handles.pTable.Data='';
dirName=dir(handles.currDir);
listing={dirName.name};
handles.fileList.String=(listing);
guidata(hObject, handles);



function sqncText_Callback(hObject, eventdata, handles)
% hObject    handle to sqncText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of sqncText as text
%        str2double(get(hObject,'String')) returns contents of sqncText as a double


% --- Executes during object creation, after setting all properties.
function sqncText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to sqncText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in loadButton.
function loadButton_Callback(hObject, eventdata, handles)
% hObject    handle to loadButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargout{1} = handles.expFile;
% delete(handles.figure1);
close(handles.figure1); 
% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure
if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
    delete(hObject);
end



function ResultsView_Callback(hObject, eventdata, handles)
% hObject    handle to ResultsView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ResultsView as text
%        str2double(get(hObject,'String')) returns contents of ResultsView as a double


% --- Executes during object creation, after setting all properties.
function ResultsView_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ResultsView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
