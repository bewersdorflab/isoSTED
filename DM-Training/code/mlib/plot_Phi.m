function [h1, h2] = plot_Phi(Phi, apmask, nobar)
if ~exist('nobar', 'var')
    nobar = 0;
end
h1 = imagesc(Phi);
set(h1, 'AlphaData', apmask);
axis equal;
axis off;
if ~nobar
    h2 = colorbar();
    ylabel(h2, '[rad]');
end
end
