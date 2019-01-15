% COMPUTE_HIGH_NA_HFZ compute high NA influence matrix.
%   [hnaH] = compute_high_NA_H()
%
%   TODO
%
% Author: Jacopo Antonello <jacopo.antonello@dpag.ox.ac.uk>
% Centre for Neural Circuits and Behaviour, University of Oxford

function [hnaHf] = compute_high_NA_H(H, zstruct, NA, n, ...
    lambda_calib, lambda_use)

nz = zstruct.ncoeff;
[zc, ~, smap] = highNAdefocus2zernike(1, zstruct, NA, n);
nsph = sum(smap);
A = eye(nz);
P = [A(:, smap == 1), A(:, smap == 0)]';
zcnorm = norm(zc);
Seye = eye(nsph);
Seye(:, 1) = zc(smap, 1);
[Q, ~] = qr(Seye);
q1 = zcnorm*Q(:, 1);
Q(:, 1) = Q(:, 2);
Q(:, 2) = q1;

KQ = [Q', zeros(nsph, nz - nsph); zeros(nz - nsph, nsph), eye(nz - nsph)];
T = P'*KQ*P;
hnaHf = (lambda_calib/lambda_use)*T*H;

% sfigure(10);
% subplot(1, 4, 1);
% z0 = 0*zc;
% z0(1) = 1;
% z1 = T*z0;
% plot(z1(1:23));
% subplot(1, 4, 2);
% z0 = 0*zc;
% z0 = zc;
% z2 = T*z0;
% plot(z2(1:23));
% subplot(1, 4, 3);
% z0 = 0*zc;
% z0(11) = 1;
% z2 = T*z0;
% plot(z2(1:23));
% subplot(1, 4, 4);
% z0 = 0*zc;
% z0(22) = 1;
% z3 = T*z0;
% plot(z3(1:23));

end
