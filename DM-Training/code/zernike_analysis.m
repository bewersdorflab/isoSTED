% clear;
% close all;
clc;

addpath('./mlib/');
addpath('./fringe/');
addpath('./mshwfs/');

% Plot a Zernike analysis of the DM calibration data. First load the
% dataset from disk or run parse_labview_data.m

% select & load a dataset
% datasetpath = 'modelling/mirao52e.mat';
% datasetpath = 'modelling/bmcmultidm140.mat';
datasetpath = 'cambridge-2016-01-25.mat';
load(datasetpath);
[~, datasetname] = fileparts(datasetpath);

apmask = dsspec.apmask;
n_radial = 16;

[zstruct, ~, ~, zapmask] = register_aperture(zernike_table(n_radial), ...
    Yout, apmask);

dbsleep = .5;
nodmplot = 0;

for i=1:size(Yout, 2)
    Phi = make_Phi(Yout(:, i), apmask, 1);
    zc = zernike_fit(zstruct, Phi);
    Phi_z = zernike_eval(zstruct, zc);

    if dbsleep > 0
        sfigure(1);
        clf();
        
        subplot(2, 2, 1);
        plot_Phi(Phi, apmask);
        title(sprintf('\\Phi rms=%.2f', sigrms(Phi)));
        
        subplot(2, 2, 2);
        plot_Phi(Phi_z, zapmask);
        title('Zernike synthesis');
        
        subplot(2, 2, 3);
        plot_Phi(abs(Phi - Phi_z), apmask.*zapmask);
        title('error');
        
        subplot(2, 2, 4);
        plot(1:numel(zc), zc);
        grid on;
        title('Zernike analysis');
        legend(sprintf('rms=%.2f', norm(zc)));
        xlim([1, numel(zc)]);

        try
            if ~nodmplot
                sfigure(2);
                clf();
                dm_plot(Uin(:, i));
            end
        catch
            close(2);
            nodmplot = 1;
        end
        
        pause(dbsleep);
    end
end
