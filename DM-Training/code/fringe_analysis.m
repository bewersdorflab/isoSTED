clear;
close all;
clc;

addpath('./mlib/');
addpath('./fringe/');
addpath('./mshwfs/');

% dblfile = 'flat-2016-02-02_18-40-21_TestImage.dbl';
dbldir = 'C:\Users\Workstation\Desktop\04-feb\ModeScan01_wFlat_ShortModes';

n_radial = 18; % use up to n_radial radial order Zernike polynomials
remove_tiptilt = 0;

% diameter of the aperture in pixels (mut be even)
fringe_mask_size = round(596*8.05/10);
calib_index = 1;

%% redefine masks using one file (if tip/tilt has changed)
listdbl = dir(sprintf('%s%s*.dbl', dbldir, filesep()));

dblfile = sprintf('%s%s%s', dbldir, filesep(), listdbl(calib_index).name);

fft_mask_type = @fourier_gauss_mask;
image = labview_read_dbl(dblfile);
masks = user_define_masks(image, fft_mask_type, fringe_mask_size);

% extract phase
fringes = image(masks.inds1, masks.inds2);
[Phi_w, apmask] = fourier_phase_extract(fringes, masks.fftmask, 100);
assert(norm(apmask(:) - masks.apmask(:)) == 0);

% unwrap phase
Phi_u = phase_unwrap(Phi_w, 101);
%% analise
for i=1:length(listdbl)
    if ~exist('zstruct', 'var') || ...
            size(zstruct.xx, 1) ~= size(image, 1) || ...
            size(zstruct.xx, 2) ~= size(image, 2)
        [zstruct, Yout, Zb, zapmask] = register_aperture(...
            zernike_table(n_radial), Phi_u(apmask), apmask);
    end
    
    dblfile = sprintf('%s%s%s', dbldir, filesep(), listdbl(i).name);
    image = labview_read_dbl(dblfile);
    fringes = image(masks.inds1, masks.inds2);
    [Phi_w, apmask] = fourier_phase_extract(fringes, masks.fftmask);
    Phi_u = phase_unwrap(Phi_w);
    
    sfigure(110);
    plot_phase_analysis(Phi_u, apmask);
    sfigure(111);
    [zhat] = plot_zernike_analysis(zstruct, Phi_u);

    if ~remove_tiptilt
        zhat(4:end) = 0;
        Phi_tt = zernike_eval(zstruct, zhat);
        
        Phi_2 = Phi_u - Phi_tt;
        
        sfigure(110);
        plot_phase_analysis(Phi_2, zapmask);
        sfigure(111);
        plot_zernike_analysis(zstruct, Phi_2);
    end
    pause(.1);
end
