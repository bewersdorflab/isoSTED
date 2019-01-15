function get_image

global hardware;
global setup

%preview(hardware.camera.vid); 
getsnapshot(hardware.camera.vid);
setup.img=getsnapshot(hardware.camera.vid); % get image from camera

setup.img=setup.img(setup.y(1):setup.y(2),setup.x(1):setup.x(2));   % crop the image manually according to edge of deformable mirror
% up-down, left-right 

% figure(11);
% imshow(setup.img,[]);

% calculate image size and center
setup.img_size=size(setup.img);
setup.img_center=round(setup.img_size/2);

end