function [zstruct, Yout, Zb, zapmask] = register_aperture(...
    zstruct, Yout, apmask)

nmeas = size(Yout, 2);

% register Zernike unit disk
xmask = logical(sum(apmask, 1));
ymask = logical(sum(apmask, 2)');

p1 = find(xmask, 1, 'first');
p2 = find(xmask, 1, 'last');
mq = [p1, 1; p2, 1]\[-1; 1];
ddx = mq(2) + (mq(1)*(1:numel(xmask)));

p1 = find(ymask, 1, 'first');
p2 = find(ymask, 1, 'last');
mq = [p1, 1; p2, 1]\[-1; 1];
ddy = mq(2) + (mq(1)*(1:numel(ymask)));

[xx, yy] = meshgrid(ddx, ddy);

zstruct = zernike_cache(zstruct, xx, yy);
zapmask = zstruct.suppmap;
znsupp = sum(zapmask(:));

% TODO merge both masks with an AND
% this should be fixed, for now zapmask is strictly inside apmask
assert(all(apmask(zapmask)));

Zb = zstruct.zi(zstruct.vsuppmap, :);

Y2 = zeros(znsupp, nmeas);
for i=1:nmeas
    Phi = make_Phi(Yout(:, i), apmask, 0);
    Y2(:, i) = Phi(zapmask);
end
Yout = Y2;

end