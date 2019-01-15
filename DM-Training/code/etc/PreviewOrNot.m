function varargout = PreviewOrNot(varargin)
% PREVIEWORNOT MATLAB code for PreviewOrNot.fig
%      PREVIEWORNOT, by itself, creates a new PREVIEWORNOT or raises the existing
%      singleton*.
%
%      H = PREVIEWORNOT returns the handle to a new PREVIEWORNOT or the handle to
%      the existing singleton*.
%
%      PREVIEWORNOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PREVIEWORNOT.M with the given input arguments.
%
%      PREVIEWORNOT('Property','Value',...) creates a new PREVIEWORNOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PreviewOrNot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PreviewOrNot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PreviewOrNot

% Last Modified by GUIDE v2.5 03-Sep-2016 11:06:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PreviewOrNot_OpeningFcn, ...
                   'gui_OutputFcn',  @PreviewOrNot_OutputFcn, ...
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


% --- Executes just before PreviewOrNot is made visible.
function PreviewOrNot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PreviewOrNot (see VARARGIN)

% Choose default command line output for PreviewOrNot
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global hardware;

preview(hardware.camera.vid);  % preview camera

% UIWAIT makes PreviewOrNot wait for user response (see UIRESUME)
uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = PreviewOrNot_OutputFcn(hObject, eventdata, handles) 

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end

% --- Executes on button press in Preview.
% preview the camera
function Preview_Callback(hObject, eventdata, handles)
global hardware;
preview(hardware.camera.vid);  % preview camera

% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
% close GUI
uiresume(handles.figure1);
close all;

% --- Executes on button press in ok.
function Gain_Callback(hObject, eventdata, handles)
global hardware;

gain = str2double(get(handles.Gain,'String'));
gain = round(gain);

% 0<=gain<=100
if gain > 100
    gain = 100;
else if gain <0
        gain = 0;
    end
end

set(handles.Gain,'String',num2str(gain));
hardware.camera.src.Gain = gain;

function Exposure_Callback(hObject, eventdata, handles)
global hardware;

exposure = str2double(get(handles.Exposure,'String'));
exposure = round(exposure);

% -13 <= exposure <= -3
if exposure > -3
    exposure = -3;
else if exposure < -13
        exposure = -13;
    end
end

set(handles.Exposure,'String',num2str(exposure));
hardware.camera.src.Exposure = exposure;


% --- Executes during object creation, after setting all properties.
function Exposure_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Gain_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
