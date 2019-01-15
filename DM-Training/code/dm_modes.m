clear;
% close all;
clc;

addpath('./mlib/');
addpath('./fringe/');

% Computes the mirror modes from a DM calibration dataset. The
% ``theoretical'' mirror modes are computed if the dataset
% (modelling/*.mat) is generated with a modelling/*.m script. The
% ``effective'' mirror modes are computed if the dataset is obtained from
% parse_labview_data.m. The mirror modes are used in the dm_plot()
% function.

% This code does a Principal Component Analysis/SVD. It is useful to see
% what the DM can do or to assess the alignment of the actuators with
% respect to the illumunated profile.

% select & load a dataset, adjust the flips
% load modelling/bmcmultidm140/bmcmultidm140.mat;
load modelling/mirao52e/mirao52e.mat;
% load testdata.mat;

plot_delay = .1;

ppa_res = 64;
dmplot_res = 64;

% TODO fix these
dmplot_fliplr = 1;
dmplot_flipud = 0;

exclude_piston = 1;

nact = size(Uin, 1);

%% Principal component analysis

[Yrs, n1rs, n2rs, apmaskrs] = resample_Yout(Yout, ...
    dsspec.apmask, ppa_res, ppa_res);
assert(all(isfinite(Yrs(:))));

try
    Yrs = fix_principal_val(Uin, Yrs, 1);
catch
    fprintf('Cannot fix piston mode.');
end
Yrs = remove_initab(Yrs);
if exclude_piston
    Yrs = remove_piston(Yrs);
end

t1 = tic();
[U, S, V] = svd(Yrs);
fprintf('svd() %.3f s\n', toc(t1));

% plot mirror modes
spmm = 4;
spnn = 4;
spc = 1;
spbase = 10;

minmax = @(a) [min(a(:)), max(a(:))];
mm = minmax(U(:));
for i=1:nact
    sfigure(spbase);
    subplot(spmm, spnn, spc);

    Phi = make_Phi(U(:, i), apmaskrs);
    assert(mean(Phi(:)) < 1e-9);

    plot_Phi(Phi, apmaskrs, 1);
    title(sprintf('%d', i));

    spc = spc + 1;
    if spc == spmm*spnn + 1
        spbase = spbase + 1;
        sfigure(spbase);
        spc = 1;
    end
end

sfigure(2);
semilogy(diag(S(1:nact, 1:nact)), 'marker', 'x');
grid on;
title('singular values \sigma_i');

%% generate data for plotting DM actuators
haslayout = 1;
try
    % use files in modelling/* to generate the actuator layout
    load plotdata_dmactpos.mat;
catch
    haslayout = 0;
end

if haslayout
    nact = size(Uin, 1);
    
    % resample data?
    [Yrs, n1rs, n2rs, apmaskrs] = resample_Yout(Yout, ...
        dsspec.apmask, dmplot_res, dmplot_res);
    
    t1 = tic();
    [U, S, V] = svd(Yrs);
    fprintf('svd() %.3f s\n', toc(t1));
    U2 = U(:, 1:nact);

    xact = -act_pos(:, 2);
    yact = -act_pos(:, 1);
    
    grow = 3;
    growstep = isp/4;
    [dx, dy] = meshgrid(linspace(-growstep, growstep, grow));
    xact = kron(ones(grow), xact) + kron(ones(nact, 1), dx);
    yact = kron(ones(grow), yact) + kron(ones(nact, 1), dy);
    % plot(xact(:), yact(:), 'x');
    % axis equal;
    tri = delaunay(xact, yact);
    % e = eye(nact);
    % for i=1:nact
    %     trisurf(tri, xact, yact, ...
    %         reshape(kron(ones(grow), e(:, i)), numel(xact), 1));
    %     shading interp;
    %     view(2);
    %     pause(.01);
    % end
    [~, ~, V2] = svd(Uin);
    V2a = V2(:, 1:nact);
    V1a = V(:, 1:nact);
    V = V2a'*V1a;
    save('plotdata_dmmodes.mat', 'grow', 'growstep', 'tri', 'act_pos', ...
        'xact', 'yact', 'U2', 'V', 'apmaskrs', ...
        'dmplot_fliplr', 'dmplot_flipud');

    % actual mirror modes / theoretical mirror modes
    for i=1:nact
        sfigure(30);
        dm_plot(V(:, i));
        pause(plot_delay);
    end
    
    % actuator pokes
    for i=1:nact
        sfigure(30);
        ei = zeros(nact, 1);
        ei(i) = 1;
        dm_plot(ei);
        pause(plot_delay);
    end
end
