function mirror_training(projectName)
% This function is designed for the mirror training process

global setup;
global hardware;

setup.img=getsnapshot(hardware.camera.vid);
totalStep = 140 * length(setup.DM.pokeArray);  % 700 = 140(actuator number) * 5(step number);
data=zeros(totalStep,setup.ROISize,setup.ROISize);  

filePath = ['DM data\' projectName];
mkdir(filePath);
mkdir([filePath '\poke image'])

%% Part 1: Loop
generate_DM_map;

for j=1:totalStep

    disp(j);
    %pause(1);
    %% Loop-Part 1: Image Acquisition
    %display('Image Acquisition');
    setup.loop=j;

    update_DM;
    get_image;

    %% Loop-Part 2: Phase Extraction
    phase_extraction;

    %% Loop-Part 3: Phase Unwrapping
    % unwrap the phase of obtained 
    phase_unwrap;

    %% Loop-Part 4: Remove Tilt
    for ii=1:setup.img_size(1)
        for jj=1:setup.img_size(2)
            % correct phase by subtracting fitted plane
            phase_tilt(ii,jj)=setup.phase(ii,jj)-setup.a0-setup.a1*ii-setup.a2*jj;
        end
    end

    setup.phase=phase_tilt;

    %% Loop-Part 5: Plot Figure Result

    FigHandle = figure(1);
    set(FigHandle,'Position', [100, 100, 1500, 895]);
    % %subplot(1,2,1);
    % imshow(setup.img,[]);
    % colormap(gray);
    % 
    % freezeColors;

    % subplot(1,2,2);
    imshow(setup.phase-setup.flat,[]);
    colormap(jet); colorbar;
    caxis([-10 10]);

    %% Loop-Part 6: Output Figure
    img_final=im2uint16(setup.phase-setup.flat);
    saveas(2,[filePath '\poke image\',num2str(j),'.tif']);

    %% Loop-Part 7: Save Data
    data(j,:,:) = setup.phase;

end

flat = setup.flat;
%% Part 
Uin=setup.DM.uin;   % actuator control matrix
save([filePath '\poke data.mat'],'data','Uin','flat');
