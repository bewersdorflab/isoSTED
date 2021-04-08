function [zplot] = make_zplot(zstruct)
zplot = zstruct;
[xx, yy] = meshgrid(linspace(-1, 1, 64));
zplot = zernike_cache(zplot, xx, yy);
end
