function [gauss] = fourier_gauss_mask(N, x0, y0, r)
sig = r/3;
[xx, yy] = meshgrid(1:N);
apmask = sqrt((xx - x0).^2 + (yy - y0).^2) <= r;
gauss = exp(-.5*((xx - x0).^2 + (yy - y0).^2)./(sig.^2));
gauss(~apmask) = 0;
end