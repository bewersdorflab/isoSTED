function [Phi] = make_Phi(Y, apmask, removepiston)
nstack = size(Y, 3);
if exist('removepiston', 'var') && removepiston == 1
    Y = remove_piston(Y);
end
Phi = -inf*ones([size(apmask), nstack]);
for i=1:nstack
    tmp = -inf*ones(size(apmask));
    tmp(apmask) = Y(:, i);
    Phi(:, :, i) = tmp;
end
Phi = squeeze(Phi);
end
