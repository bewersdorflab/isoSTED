%% read all zernike shapes
clear;
clc;
close all;
addpath('../mlib/');
addpath('../mshwfs/');

basedir = [...
    '../../Interferometric-Calib151130-1125/' ...
    'Interferometric-Calib151130-1125-zernike-shapes/' ...
    'Lp-52-135-2015-11-30_15-02-59'];
dirlist = dir(sprintf('%s%s*.mat', basedir, filesep()));
load(sprintf('%s%s%s', basedir, filesep(), dirlist(1).name));
phasesize = size(Phi0w);
phasesall = zeros(numel(Phi0w), length(dirlist));
for myi=1:length(dirlist)
    whos
    load(sprintf('%s%s%s', basedir, filesep(), dirlist(myi).name));
    whos
    
    % Unwrap the phase in Python using the 2D algorithm from Miguel
    % Arevallilo Herráez, David R. Burton, Michael J. Lalor, and
    % Munther A. Gdeisat, "Fast two-dimensional phase-unwrapping
    % algorithm based on sorting by reliability following a
    % noncontinuous path," Appl. Opt. 41, 7437-7444 (2002).
    % To execute this you need Anaconda for Python3.
    tmp = Phi0w;
    tmpid = tempname();
    tmpin = [tmpid, '.mat'];
    save(tmpin, 'tmp');
    clear tmp;
    unix(sprintf('python ../unwrap.py --quiet %s', tmpin));
    tmpout = [tmpid, '_unwrapped.mat'];
    load(tmpout);
    delete(tmpin);
    delete(tmpout);

    Phiu = tmp;
    sfigure(1);
    subplot(1, 2, 1);
    imagesc(Phi0w);
    axis equal;
    subplot(1, 2, 2);
    imagesc(Phiu);
    axis equal;
    pause(.1);

    clear Phi0 Phi0w tmp tmpid tmpin tmpout;
    phasesall(:, myi) = Phiu(:);
end
save tmp.mat phasesall;


%%
clear;
clc;
close all;
addpath('../mlib/');
addpath('../mshwfs/');

load ../Interferometric-Calib151130-1125-train.mat;
load tmp;


siz = sqrt(size(phasesall, 1));
assert(size(apmask, 1) == siz);
assert(size(apmask, 2) == siz);
amps = [0, 8*ones(1, 14), 4*ones(1, 9)];

zs2 = zstruct;
dd = linspace(-1, 1, siz);
[xx, yy] = meshgrid(dd);
zs2 = zernike_cache(zs2, xx, yy);


for i=1:size(phasesall, 2)
    Phi = reshape(phasesall(:, i), siz, siz);
    Phi(~apmask) = -inf;
    Phi(apmask) = Phi(apmask) - mean(Phi(apmask));

    zmeas = zernike_fit(zstruct, Phi);
    zhat = zeros(size(zmeas));
    zhat(i) = amps(i);
    zhat = labview2matlab(zstruct, zhat);
    
    sfigure(1);

    subplot(2, 2, 1);
    [~, ~, ~, ~, ~, h] = plot_phase_analysis(Phi, apmask);
    set(h, 'FontSize', 8, 'FontWeight', 'Normal');
%     h = imagesc(Phi);
%     set(h, 'AlphaData', apmask);
%     axis equal;
%     axis off;
    
    subplot(2, 2, 2);
    [~, ~, ~, ~, ~, h] = plot_phase_analysis(...
        abs(Phi - zernike_eval(zs2, zhat)), ...
        apmask, 'abserr');
    set(h, 'FontSize', 8, 'FontWeight', 'Normal');
%     h = imagesc(err);
%     set(h, 'AlphaData', apmask);
%     axis equal;
%     axis off;
%     title('abs error');
  
    subplot(2, 2, 3:4);
    plot(1:numel(zmeas), [zhat, zmeas], 'marker', '.');
    grid on;
    legend(...
        sprintf('zhat %.2f', norm(zhat(2:end))), ...
        sprintf('meas %.2f', norm(zmeas(2:end))), ...
        'location', 'southeast');
    title('zernike fits');
    xlabel('# zernike');
    ylabel('[rad]');

    save_png(sprintf('../pngs%stestzern%05d.png', filesep(), i), '-r300');
end
delete('tmp.mat');


