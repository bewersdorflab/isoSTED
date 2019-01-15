% STEP 5
% analysize the data

clear all;
close all;
clc;

projectName = '13RW018#054';
folderName = dir(['.\DM data\' projectName '*']);

load(['.\DM data\' folderName.name '\test data\data.mat']);  % measured phases for each mode (data)
% load(['.\DM data\' folderName.name '\test data\flat.mat']);  % measured phase when flatmap is added (flat)
load('setup.mat');  % initial setup parameters (setup)

img_size = setup.img_size;   % image size
img_center = setup.img_center;  % image center
mask_radius = setup.mask_radius;  % mask radius
clear setup;

%% data processing

% remove the static pattern on DM
phase = zeros(size(data,1),2*mask_radius-1,2*mask_radius-1);
flat = reshape(flat,[1,size(flat,1),size(flat,2)]);
for j = 1:size(data,1)
    temp = data(j,:,:) - flat;
    temp = temp(1,(img_center(2)-(mask_radius - 1)):(img_center(2)+(mask_radius-1)),(img_center(1)-(mask_radius-1)):(img_center(1)+(mask_radius-1)));
    
    phase(j,:,:) = temp;
    
    imshow(squeeze(phase(j,:,:)),[]);colormap(parula);
    axis image;
    
    pause(0.1);
end

mkdir(['.\DM data\' folderName.name '\analysis data']);
save(['.\DM data\' folderName.name '\analysis data\phase.mat'],'phase');