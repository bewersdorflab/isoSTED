function [bump] = fourier_bump_mask(N, x0, y0, r)
[xx, yy] = meshgrid(1:N);
apmask = sqrt((xx - x0).^2 + (yy - y0).^2) <= r;
bump = exp(-(1 - (1/r^2)*((xx - x0).^2 + (yy - y0).^2)).^(-1));
bump(~apmask) = 0;
end