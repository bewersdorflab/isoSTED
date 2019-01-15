clear all;
close all;
clc;

addpath('.\code\etc');
addpath('.\code\hardware');
addpath('.\code\mex_files');
addpath('.\code\mirror_training');

% DM to be trained
DMSN = '13RW018#054';
DMPath = ['.\DM resources\' DMSN];
addpath(DMPath);

global setup;
global hardware;


%% Parameters
flatFilePath = [DMPath '\Flat Map\CLOSED_LOOP.mat'];
load(flatFilePath,'DM_voltage_map');  % load DM_voltage_map or flat_map
flat_map = DM_voltage_map/3;  % valid input for matlab is 0~100
setup.DM.flat_map=flat_map;   % set flat file
pokeStepNumber = 3;
setup.DM.pokeArray = linspace(775,-775,pokeStepNumber);   % true height (unit: nm) = poke value * delta;

projectName = [DMSN '_calib_' num2str(pokeStepNumber) '_' datestr(now,'yyyymmmdd_HH_MM_SS')];

%% Part 0: Hardware Initialization
% Intialize deformable mirror and camera (from Boston Micromachine... &
% Thorlabs...)
hardware_init;

%% Camera parameter settings
hardware.camera.src.ExposureMode = 'manual';
hardware.camera.src.Exposure = -13;
hardware.camera.src.GainMode = 'manual';
hardware.camera.src.Gain = 0;

%% set parameters
PreviewOrNot;   % preview the camera and adjust the camera setting

% set ROI
% initial guess of ROI
setup.x=[352,946];  % crop left-right
setup.y=[225,819];  % crop top-down
setup.signal_cor=[388,230];   % corrdinate of signal peak (Fourier Space)
setup.signal_size=[40,40];    % size of signal peak to crop (Fourier Space)
setup.flag=true;
setup.delta=1;   % (nm) height defined as 1, in training

if setup.x(2)-setup.x(1) == setup.y(2)-setup.y(1)
    setup.ROISize = setup.x(2)-setup.x(1) + 1;
else
    error('Please confirm RIO is a square area!');
end

flag = false;
while ~flag
    % define ROI in the image
    setup.img=getsnapshot(hardware.camera.vid);
    ChooseROI;
    
    % define ROI in Fourier space
    ROIinFourier;
    
    % extract phase
    get_image;
    phase_extraction;
    phase_unwrap;
    remove_tilt;
    
    imagesc(setup.phase);
    axis image;  axis off;
    caxis([-10 10]);
    colorbar;
    
    setup.flat = setup.phase;
    
    % confirm the definition
    satisfied = ConfirmROI();
    switch satisfied
        case 'Yes'
            flag = true;
        case 'No'
            flag = false;
        otherwise
            error('invalid!');
    end
    close all;
end

save('setup.mat','setup');   % save setup data for further use

%% Part 2: Mirror Training
% run mirror training part
tic;
mirror_training(projectName);
close all;
toc;

%% Part 3: Hardware Finalization
hardware_close;
clear hardware;