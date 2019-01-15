function [y] = resampleinterp(x, siz)
mask = isfinite(x);
x(~mask) = 0;
[xx1, xx2]= meshgrid(...
    linspace(1, size(x, 1), siz(1)), ...
    linspace(1, size(x, 2), siz(2)));
y = interp2(x, xx1, xx2, 'spline');
end