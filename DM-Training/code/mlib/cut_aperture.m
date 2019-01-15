function [Yout, apmask] = cut_aperture(Yout, oldapmask, radius_factor)

if radius_factor == 1
    apmask = oldapmask;
    return
end
assert(radius_factor > 0);
assert(radius_factor < 1);

dd1 = linspace(-1/radius_factor, 1/radius_factor, size(oldapmask, 1));
[xx1, yy1] = meshgrid(dd1);
innerapmask = sqrt(xx1.^2 + yy1.^2) <= 1;
sum1 = sum(innerapmask, 1);
sum2 = sum(innerapmask, 2);
N1 = max(sum1(:));
N2 = max(sum2(:));
newN = max([N1, N2]);

dd2 = linspace(-1, 1, newN);
[xx2, yy2] = meshgrid(dd2);
newapmask = fourier_apmask(randn(newN));

Yout2 = zeros(sum(newapmask(:)), size(Yout, 2));
for i=1:size(Yout2, 2)
    Phi1 = make_Phi(Yout(:, i), oldapmask);
    Phi1(~oldapmask) = 0;
    Phi2 = interp2(xx1, yy1, Phi1, xx2, yy2, 'linear', 0);
    Yout2(:, i) = Phi2(newapmask);
    imagesc(Phi2);
    pause(.1);
end

Yout = Yout2;
apmask = newapmask;
end