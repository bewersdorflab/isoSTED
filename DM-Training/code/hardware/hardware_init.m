function hardware_init

global hardware;
global setup;

%% Part 1: Video Input Configuration
% the property and id of device should be selected manually from image
% acquisition toolbox
hardware.camera.num=1;
hardware.camera.vid = videoinput('winvideo', hardware.camera.num, 'RGB32_1280x1024');

% change the color space of the returned image data.
hardware.camera.vid.ReturnedColorSpace = 'grayscale';
hardware.camera.src=getselectedsource(hardware.camera.vid);

%% Part 2: Deformable Mirror Configuration
mapping_ID = 6; 
[hardware.DM.error_code, hardware.DM.driver_info] = OPEN_multiDM(mapping_ID); 
UPDATE_multiDM(hardware.DM.driver_info, setup.DM.flat_map);  % add flatmap

end