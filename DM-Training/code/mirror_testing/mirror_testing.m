function mirror_testing(flatmap,C,projectName)
% This function is designed for the mirror training process

global setup;

data=zeros(setup.zernike_poly_num,setup.y(2) - setup.y(1) + 1,setup.x(2) - setup.x(1) + 1);

%% Part 1: Loop
% create folder for data storage
folderName = dir(['.\DM data\' projectName '*']);
mkdir(['.\DM data\' folderName.name '\test data\image'])

% loop start
for i=1:setup.zernike_poly_num
    disp(i);
    %pause(1);
    %% Loop-Part 1: Image Acquisition
    %display('Image Acquisition');
    setup.loop=i;

    generate_DM_map_for_testing(flatmap,C);
    update_DM;
    get_image;

    %% Loop-Part 2: Phase Extraction
    phase_extraction;

    %% Loop-Part 3: Phase Unwrapping
    % unwrap the phase of obtained 
    phase_unwrap;

    %% Loop-Part 4: Remove Tilt
    remove_tilt;

    %% Loop-Part 5: Generate mask

    mask_radius=setup.mask_radius;
    pixel_num=size(setup.phase,1);

    x=linspace(-pixel_num/2,pixel_num/2,pixel_num); y=x;
    [Y,X]=meshgrid(x,y);
    R=sqrt(X.^2+Y.^2);
    mask=R<=mask_radius;

    setup.phase=setup.phase.*mask;

    %% Loop-Part 5: Plot Figure Result

    FigHandle = figure(1);
     set(FigHandle,'Position', [100, 100, 1500, 895]);
    % %subplot(1,2,1);
    % imshow(setup.img,[]);
    % colormap(gray);
    % 
    % freezeColors;

    % subplot(1,2,2);
    imshow(setup.phase,[]);
    colormap(jet); colorbar;
    caxis([-5 5]);

    %% Loop-Part 6: Output Figure
    img_final=im2uint16(setup.phase);
    saveas(1,['.\DM data\' folderName.name '\test data\image\',num2str(i),'.tif']);

    %% Loop-Part 7: Save Data11
    data(i,:,:)=setup.phase;

end

%% Part 

save(['.\DM data\' folderName.name '\test data\data.mat'],'data');



