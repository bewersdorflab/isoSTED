function hardware_close

global hardware;

% close DM
hardware.DM.error_code = CLOSE_multiDM(hardware.DM.driver_info);
% close camera
delete(hardware.camera.vid);

end