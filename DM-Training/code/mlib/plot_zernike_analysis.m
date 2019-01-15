function [zhat] = plot_zernike_analysis(zs, Phi, mm, nn, sp1, sp2)

if (~exist('nn', 'var') || isempty(nn)) || ...
        (~exist('mm', 'var') || isempty(mm)) || ...
        (~exist('sp1', 'var') || isempty(sp1)) || ...
        (~exist('sp2', 'var') || isempty(sp2))
    nn = 1;
    mm = 2;
    sp1 = 1;
    sp2 = 2;
end

[zhat, ~, rer] = zernike_fit(zs, Phi);
zhat(1) = 0;

subplot(mm, nn, sp1);
zplot = make_zplot(zs);
zernike_imagesc(zplot, zhat);
axis equal;
axis off;
title(sprintf('analysis %d Zernike modes', zs.ncoeff));

subplot(mm, nn, sp2);
plot(1:numel(zhat), zhat, 'marker', 'o');
rms1 = norm(zhat);
strehl = exp(-norm(zhat).^2);
title(sprintf('strehl=%.3f rms1=%.2f rer=%.2f%%', strehl, rms1, 100*rer));
xaxis = 1:numel(zhat);
if numel(xaxis) > 7
    inds = 1:floor(numel(xaxis)/7):numel(xaxis);
    set(gca, 'XTick', inds, 'XTickLabel', xaxis(inds));
else
    set(gca, 'XTick', 1:numel(zab));
end
% xlim([1, numel(zhat)]);
grid on;

end