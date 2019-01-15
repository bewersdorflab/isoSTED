function [apmask, N] = fourier_apmask(fringes)

N = size(fringes, 1);
assert(size(fringes, 2) == N);
assert(rem(N, 2) == 0); % use only even grids

% circular aperture mask
[xx, yy] = meshgrid(linspace(-N/2, N/2, N));
apmask = sqrt(xx.^2 + yy.^2) <= N/2;

end