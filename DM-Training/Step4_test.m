% STEP 4
% import control matrix and test the data

clear all;
close all;
clc;

projectName = '13RW018#054';

addpath('.\code\etc');
addpath('.\code\hardware');
addpath('.\code\mex_files');
addpath('.\code\mirror_testing');
addpath(['.\DM resources\' projectName]);

load(['.\DM resources\' projectName '\Flat Map\CLOSED_LOOP.mat'],'DM_voltage_map');   % load flat map: DM_voltage_map
folderName = dir(['.\DM data\' projectName '*']);
load(['.\DM data\' folderName.name '\control matrix and flatmap\control matrix.mat'],...
    'Cf_LabVIEW');  % load control matrix: Cf_LabVIEW

%% Parameters
formerSetup = ChangeVariableName('setup.mat');

global setup;
global hardware;

setup.zernike_poly_num = 100;
setup.x=formerSetup.x;  % crop left-right
setup.y=formerSetup.y;  % crop top-down
setup.signal_cor=formerSetup.signal_cor;   % corrdinate of signal peak (Fourier Space)
setup.signal_size=formerSetup.signal_size;    % size of signal peak to crop (Fourier Space)
setup.flag=formerSetup.flag;
setup.delta=formerSetup.delta;   % (nm) height defined as 1, in training
setup.mask_radius = formerSetup.mask_radius;  % mask radius
setup.DM.flat_map=DM_voltage_map/3;   % set flat file

clear formerSetup;

%% Part 1: Hardware Initialization
% Intialize deformable mirror and camera (from Boston Micromachine... &
% Thorlabs...)
hardware.camera.num=1;

hardware_init;

%% Camera parameter settings
hardware.camera.src.ExposureMode = 'manual';
hardware.camera.src.Exposure = -13;
hardware.camera.src.GainMode = 'manual';
hardware.camera.src.Gain = 0;

%% Part 2: Mirror Testing
% run mirror training part
mirror_testing(DM_voltage_map/3,Cf_LabVIEW,projectName);

%% Part 3: Hardware Finalization
hardware_close;
clear hardware;