clear;
clc;
close all;
addpath('../mlib/');
addpath('../mshwfs/');

% TODO finish & fix up this file

% trainfile = '../Interferometric-Calib150922-1723-train.mat';
% trainfile = '../Interferometric-Calib150924-1714-train.mat';
trainfile = '../Interferometric-Calib151130-1125-train.mat';

load(trainfile);
res = '-r300';

zplot = zstruct;
[xx, yy] = meshgrid(linspace(-1, 1, 128));
zplot = zernike_cache(zplot, xx, yy);

[U, S, V] = svd(H);

[nz, nu] = size(S);

U1 = U(:, 1:nu);
U2 = U(:, nu+1:nz);

sfigure(1);
semilogy(svd(H), 'marker', 'o');
grid on;
title(sprintf('cond(H) = %g', cond(H)));
save_png('../pngs/H.png', res);

sv = svd(H);
%% colspace
for i=1:size(U1, 2)
    sfigure(2);

    zc = zeros(zstruct.ncoeff, 1);
    zc(2:end) = U1(:, i);

    subplot(2, 2, 1);
    zernike_imagesc(zplot, zc);
    axis equal;
    axis off;
    title(sprintf('sv %.3f', S(i, i)));

    subplot(2, 2, 2);
    semilogy(sv, 'marker', 'o');
    grid on;
    hold on;
    semilogy(i, sv(i), 'rx', 'markersize', 12);
    hold off;
    title(sprintf('cond(H) = %g', cond(H)));
    
    subplot(2, 2, 3:4);
    plot(1:numel(zc), zc, 'marker', '.');
    rms1 = norm(zc);
    strehl = exp(-norm(zc).^2);
%     title(sprintf('strehl=%.3f rms1=%.2f rer=%.2f%%', strehl, rms1, 100*rer));
    xaxis = 1:numel(zc);
    if numel(xaxis) > 7
        inds = 1:floor(numel(xaxis)/7):numel(xaxis);
        set(gca, 'XTick', inds, 'XTickLabel', xaxis(inds));
    else
        set(gca, 'XTick', 1:numel(zab));
    end
    % xlim([1, numel(zc)]);
    grid on;
    ylabel('[rad]');
    xlabel('zernike #');

    pause(.1);
    save_png(sprintf('../pngs/colspace%06d.png', i), res);
end
%% null space
jtonm = zstruct.jtonmtable;
for i=1:size(U2, 2)
    sfigure(3);

    zc = zeros(zstruct.ncoeff, 1);
    zc(2:end) = U2(:, i);

    subplot(2, 2, 1);
    zernike_imagesc(zplot, zc);
    axis equal;
    axis off;
    title('null space');

    subplot(2, 2, 3:4);
    plot(1:numel(zc), zc, 'marker', '.');
    rms1 = norm(zc);
    strehl = exp(-norm(zc).^2);
    xaxis = 1:numel(zc);
    if numel(xaxis) > 7
        inds = 1:floor(numel(xaxis)/7):numel(xaxis);
        set(gca, 'XTick', inds, 'XTickLabel', xaxis(inds));
    else
        set(gca, 'XTick', 1:numel(zab));
    end
    % xlim([1, numel(zc)]);
    grid on;
    ylabel('[rad]');
    xlabel('zernike #');
    [~, imaxzc] = max(abs(zc));
    title(sprintf('max Z_{%d} Z_{%d}^{%d}', imaxzc, ...
        jtonm(imaxzc, 1), jtonm(imaxzc, 2)));

    pause(.1);
    save_png(sprintf('../pngs/nullspace%06d.png', i), res);
end
%%

% zplot = zs;
% [xx, yy] = meshgrid(linspace(-1, 1, 128));
% zplot = zernike_cache(zplot, xx, yy);
% zernike_imagesc(zplot, zc);
% axis equal;
% axis off;
% title(sprintf('analysis %d Zernike modes', zs.ncoeff));



