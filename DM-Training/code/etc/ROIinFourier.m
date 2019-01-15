function varargout = ROIinFourier(varargin)
% ROIINFOURIER MATLAB code for ROIinFourier.fig
%      ROIINFOURIER, by itself, creates a new ROIINFOURIER or raises the existing
%      singleton*.
%
%      H = ROIINFOURIER returns the handle to a new ROIINFOURIER or the handle to
%      the existing singleton*.
%
%      ROIINFOURIER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROIINFOURIER.M with the given input arguments.
%
%      ROIINFOURIER('Property','Value',...) creates a new ROIINFOURIER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROIinFourier_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROIinFourier_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROIinFourier

% Last Modified by GUIDE v2.5 03-Sep-2016 14:32:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROIinFourier_OpeningFcn, ...
                   'gui_OutputFcn',  @ROIinFourier_OutputFcn, ...
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


% --- Executes just before ROIinFourier is made visible.
function ROIinFourier_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROIinFourier (see VARARGIN)

% Choose default command line output for ROIinFourier
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global setup;
global freq_abs_log;

set(handles.centerX,'String',num2str(setup.signal_cor(1)));
set(handles.centerY,'String',num2str(setup.signal_cor(2)));
set(handles.r,'String',num2str(setup.signal_size(1)));

img=setup.img(setup.y(1):setup.y(2),setup.x(1):setup.x(2));
freq=fft2(img);
freq_shift=fftshift(freq);  % shift zero-frequency to center
freq_abs=abs(freq_shift);   % take the norm of complex number
freq_abs_log=log(freq_abs);    % use log to smoothen the image for display

axes(handles.fourierSpace);
imagesc(freq_abs_log);
axis image;
axis off;
colormap('Parula');

freqROI = freq_abs_log((-setup.signal_size(1) + setup.signal_cor(2)):(setup.signal_size(1) + setup.signal_cor(2)),...
    (-setup.signal_size(2) + setup.signal_cor(1)):(setup.signal_size(2) + setup.signal_cor(1)));

axes(handles.fourierROI);
imagesc(freqROI);
axis image;
colormap('Parula');

% UIWAIT makes ROIinFourier wait for user response (see UIRESUME)
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
function varargout = ROIinFourier_OutputFcn(hObject, eventdata, handles) 


% --- Executes on button press in zoomIn.
function zoomIn_Callback(hObject, eventdata, handles)
axes(handles.fourierSpace);
zoom on;

% --- Executes on button press in zoomOut.
function zoomOut_Callback(hObject, eventdata, handles)
axes(handles.fourierSpace);
zoom out;

% --- Executes on button press in defineCenter.
function defineCenter_Callback(hObject, eventdata, handles)
global freq_abs_log;
zoom off;

axes(handles.fourierSpace);
% [x,y] = myginput(1,'Color','r');
[x,y] = ginput(1);
x = round(x);  y = round(y);
set(handles.centerX,'String',num2str(x));
set(handles.centerY,'String',num2str(y));

r = str2double(get(handles.r,'String'));
freqROI = freq_abs_log((-r + y):(r + y),(-r + x):(r + x));

axes(handles.fourierROI);
imagesc(freqROI);
axis image;
axis off;
colormap('Parula');


function centerX_Callback(hObject, eventdata, handles)
global freq_abs_log;

x = str2double(get(handles.centerX,'String'));
x = round(x);
set(handles.centerX,'String',x);

r = str2double(get(handles.r,'String'));
y = str2double(get(handles.centerY,'String'));
freqROI = freq_abs_log((-r + y):(r + y),(-r + x):(r + x));

axes(handles.fourierROI);
imagesc(freqROI);
axis image;
axis off;
colormap('Parula');

% --- Executes during object creation, after setting all properties.
function centerX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to centerX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function centerY_Callback(hObject, eventdata, handles)
global freq_abs_log;

y = str2double(get(handles.centerY,'String'));
y = round(y);
set(handles.centerY,'String',y);

r = str2double(get(handles.r,'String'));
x = str2double(get(handles.centerX,'String'));
freqROI = freq_abs_log((-r + y):(r + y),(-r + x):(r + x));

axes(handles.fourierROI);
imagesc(freqROI);
axis image;
axis off;
colormap('Parula');

% --- Executes during object creation, after setting all properties.
function centerY_CreateFcn(hObject, eventdata, handles)
% hObject    handle to centerY (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function r_Callback(hObject, eventdata, handles)
global freq_abs_log;

r = str2double(get(handles.r,'String'));
r = round(r);
set(handles.r,'String',r);

y = str2double(get(handles.centerY,'String'));
x = str2double(get(handles.centerX,'String'));
freqROI = freq_abs_log((-r + y):(r + y),(-r + x):(r + x));

axes(handles.fourierROI);
imagesc(freqROI);
axis image;
axis off;
colormap('Parula');

% --- Executes during object creation, after setting all properties.
function r_CreateFcn(hObject, eventdata, handles)
% hObject    handle to r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ok.
function ok_Callback(hObject, eventdata, handles)
global setup;

setup.signal_cor(1) = str2double(get(handles.centerX,'String'));
setup.signal_cor(2) = str2double(get(handles.centerY,'String'));
setup.signal_size = [str2double(get(handles.r,'String')),str2double(get(handles.r,'String'))];

% close GUI
uiresume(handles.figure1);
close all;