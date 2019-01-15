% STEP 2
% add the aperture mask to the measured data

global par;

projectName = '13RW018#054';
% load Uin and data
folderName = [projectName '_calib_3_2016Sep06_18_13_38'];
load(['.\DM data\' folderName '\poke data.mat']);

%% Parameters

pixelSize = 7.83e-6;  % pixelSize (measured in experiment) in the image, unit: m
apertureSize = 4.37e-3;  % practical aperture of DM based on Zemax design, unit: m
apertureSize = apertureSize+par.aperture_size;
par.apertureSize = apertureSize;
calibration_lambda=775e-9;  % wavelength of light for illumination, unit: m

frame_num=size(data,1);
pixel_num=size(data,2);    % number of pixels used to model across mirror
mask_radius=round(par.apertureSize/pixelSize/2);

% save mask for further use
load('setup.mat');   % load setup
setup.mask_radius = mask_radius;
save('setup.mat','setup');

newDir = ['.\DM data\' 'result\' folderName '\size=' num2str(par.apertureSize) ...
    '_shift_x=' num2str(par.aperture_shift_x) '_shift_y=' num2str(par.aperture_shift_y)];
mkdir(newDir);

%% Part 1: Generate circular mask

x=linspace(-pixel_num/2,pixel_num/2,pixel_num); y=x;
[Y,X]=meshgrid(x,y);

X = X-par.aperture_shift_x*ones(pixel_num,pixel_num)/pixelSize;
Y = Y-par.aperture_shift_y*ones(pixel_num,pixel_num)/pixelSize;

R=sqrt(X.^2 + Y.^2);
mask = R <= mask_radius;
mask_new=reshape(mask,[1,pixel_num,pixel_num]); % reshape into 3-dim mask
par.mask = mask;

%% Part 2: Remove the static pattern on DM
data_flat = data(2:3:419,:,:);
flat = mean(data_flat,1);
% mkdir([newDir '\poke image 2\']);

for i = 1:frame_num
    data_orig = squeeze(data(i,:,:));
    data(i,:,:) = data(i,:,:)-flat;
    data_sub = squeeze(data(i,:,:));

%     figure(1);
%     subplot(1,2,1);
%     imshow(data_orig,[]);colormap(jet);
%     subplot(1,2,2);
%     imshow(data_sub,[]);colormap(jet);colorbar;caxis([-10 10]);
%     saveas(1,[newDir '\poke image 2\',num2str(i),'.tif']);
end

%% Part 3: Load and Lineralize Data Array and Apply Circular Mask (for data analysis)

flag=mask(:);

Yout_temp=zeros(pixel_num,pixel_num,frame_num);
% Yout_line=zeros(pixel_num*pixel_num,frame_num);

for i=1:frame_num
    Yout_temp(:,:,i)=data(i,:,:).*mask_new;
end

% reshape using circular mask
Yout_line=reshape(Yout_temp,[pixel_num * pixel_num,frame_num]);
Yout=Yout_line(flag == 1,:);
dsspec.apmask=mask;

%% Save data

save([newDir '\poke data_converted.mat'],'Yout','Uin','dsspec','calibration_lambda','apertureSize');
setup.newDir = newDir;




