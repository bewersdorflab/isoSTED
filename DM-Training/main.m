clear all;
close all;
clc;

global par;

%% parameter settings
shift_num = 5;
size_num = 11;

shift_min = -0.14e-3;
shift_max = 0.14e-3;

size_min = -2e-3;
size_max = 0.14e-3;

aperture_shift_x = linspace(shift_min,shift_max,shift_num);
aperture_shift_y = aperture_shift_x;
aperture_size = linspace(size_min,size_max,size_num);

%% 

for i = 1:size_num
    for j = 1:shift_num
        for k = 1:shift_num
            
            close all;
            tic;
            par.aperture_shift_x = aperture_shift_x(j);
            par.aperture_shift_y = aperture_shift_y(k);
            par.aperture_size = aperture_size(i);
            
            display('Step 2 - Convert data');
            Step2_convert_data;
            display('Step 3 - DM calib');
            Step3_DM_calib;
            toc;
            
        end
    end
end




