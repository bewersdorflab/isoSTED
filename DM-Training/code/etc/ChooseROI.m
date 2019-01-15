function varargout = ChooseROI(varargin)
% CHOOSEROI MATLAB code for ChooseROI.fig
%      CHOOSEROI, by itself, creates a new CHOOSEROI or raises the existing
%      singleton*.
%
%      H = CHOOSEROI returns the handle to a new CHOOSEROI or the handle to
%      the existing singleton*.
%
%      CHOOSEROI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHOOSEROI.M with the given input arguments.
%
%      CHOOSEROI('Property','Value',...) creates a new CHOOSEROI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ChooseROI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ChooseROI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ChooseROI

% Last Modified by GUIDE v2.5 05-Sep-2016 10:36:35

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ChooseROI_OpeningFcn, ...
                   'gui_OutputFcn',  @ChooseROI_OutputFcn, ...
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


% --- Executes just before ChooseROI is made visible.
function ChooseROI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ChooseROI (see VARARGIN)

% Choose default command line output for ChooseROI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global setup;

set(handles.Xmin,'String',num2str(setup.x(1)));
set(handles.Xmax,'String',num2str(setup.x(2)));
set(handles.Ymin,'String',num2str(setup.y(1)));
set(handles.Ymax,'String',num2str(setup.y(2)));
set(handles.ROISize,'String',num2str(setup.ROISize));

axes(handles.snapshot);
imshow(setup.img);
axis image;
colormap('Parula');

ROI = setup.img(setup.y(1):setup.y(2),setup.x(1):setup.x(2));
axes(handles.roi);
imshow(ROI);
axis image;
colormap('Parula');

% UIWAIT makes ChooseROI wait for user response (see UIRESUME)
uiwait(handles.figure1);

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

% --- Outputs from this function are returned to the command line.
function varargout = ChooseROI_OutputFcn(hObject, eventdata, handles) 


% --- Executes on button press in retake.
function retake_Callback(hObject, eventdata, handles)

global setup;
global hardware;

setup.img=getsnapshot(hardware.camera.vid);

axes(handles.snapshot);
imshow(setup.img);
axis image;
colormap('Parula');

ROI = setup.img(str2double(get(handles.Ymin,'String')):str2double(get(handles.Ymax,'String')),...
    str2double(get(handles.Xmin,'String')):str2double(get(handles.Xmax,'String')));
axes(handles.roi);
imshow(ROI);
axis image;
colormap('Parula');

% --- Executes on button press in choose.
function choose_Callback(hObject, eventdata, handles)
axes(handles.snapshot);
% [x,y] = myginput(2,'Color','r');
[x,y] = ginput(2);
x = round(x);   y = round(y);
ROIx = x(2) - x(1) + 1;
ROIy = y(2) - y(1) + 1;
ROISize = max(ROIx,ROIy);

set(handles.Xmin,'String',num2str(x(1)));
set(handles.Xmax,'String',num2str(x(1) + ROISize - 1));
set(handles.Ymin,'String',num2str(y(1)));
set(handles.Ymax,'String',num2str(y(1) + ROISize - 1));
set(handles.ROISize,'String',num2str(ROISize));

global setup;
ROI = setup.img(str2double(get(handles.Ymin,'String')):str2double(get(handles.Ymax,'String')),...
    str2double(get(handles.Xmin,'String')):str2double(get(handles.Xmax,'String')));
axes(handles.roi);
imshow(ROI);
axis image;
colormap('Parula');

% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
global setup;

% export parameters
setup.x = [str2double(get(handles.Xmin,'String')),str2double(get(handles.Xmax,'String'))];
setup.y = [str2double(get(handles.Ymin,'String')),str2double(get(handles.Ymax,'String'))];
setup.ROISize = str2double(get(handles.ROISize,'String'));

% close GUI
uiresume(handles.figure1);
close all;

function Xmin_Callback(hObject, eventdata, handles)
global setup;

Xmin = str2double(get(handles.Xmin,'String'));
ROISize = str2double(get(handles.ROISize,'String'));
Xmax = Xmin + ROISize - 1;
set(handles.Xmax,'String',num2str(Xmax));

ROI = setup.img(str2double(get(handles.Ymin,'String')):str2double(get(handles.Ymax,'String')),...
    str2double(get(handles.Xmin,'String')):str2double(get(handles.Xmax,'String')));
axes(handles.roi);
imshow(ROI);
axis image;
colormap('Parula');

% --- Executes during object creation, after setting all properties.
function Xmin_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Ymin_Callback(hObject, eventdata, handles)
global setup;

Ymin = str2double(get(handles.Ymin,'String'));
ROISize = str2double(get(handles.ROISize,'String'));
Ymax = Ymin + ROISize - 1;
set(handles.Ymax,'String',num2str(Ymax));

ROI = setup.img(str2double(get(handles.Ymin,'String')):str2double(get(handles.Ymax,'String')),...
    str2double(get(handles.Xmin,'String')):str2double(get(handles.Xmax,'String')));
axes(handles.roi);
imshow(ROI);
axis image;
colormap('Parula');

% --- Executes during object creation, after setting all properties.
function Ymin_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ROISize_Callback(hObject, eventdata, handles)
global setup;

ROISize = str2double(get(handles.ROISize,'String'));
Xmin = str2double(get(handles.Xmin,'String'));
Ymin = str2double(get(handles.Ymin,'String'));

Xmax = Xmin + ROISize - 1;
set(handles.Xmax,'String',num2str(Xmax));
Ymax = Ymin + ROISize - 1;
set(handles.Ymax,'String',num2str(Ymax));

ROI = setup.img(str2double(get(handles.Ymin,'String')):str2double(get(handles.Ymax,'String')),...
    str2double(get(handles.Xmin,'String')):str2double(get(handles.Xmax,'String')));
axes(handles.roi);
imshow(ROI);
axis image;
colormap('Parula');

% --- Executes during object creation, after setting all properties.
function ROISize_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in preview.
function preview_Callback(hObject, eventdata, handles)
global hardware;

preview(hardware.camera.vid);