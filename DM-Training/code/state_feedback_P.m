% clear;
% close all;
clc;

addpath('./mlib/');
addpath('./fringe/');
addpath('./mshwfs/');

% TODO tidy this up

% Computes and tests a state space proportional controller with Tikhonov
% regularisation. It is assumed that the system is observable but not
% controllable, since not all Zernike modes can be reproduced by the DM.
% The control law is uk = -Lp*labview_zernike_decomposition.

% select & load a dataset
% datasetpath = 'modelling/mirao52e.mat';
% datasetpath = 'modelling/bmcmultidm140.mat';
datasetpath = 'cambridge-2016-01-25.mat';
load(datasetpath);
[~, datasetname] = fileparts(datasetpath);

n_radial = 16;

ssmatrixdir = '.';

% apply simple Tikhonov regularisation
do_regularisation = 1;
tikhonov_filter_perc = 0.9; % place filter at 90% of singular values?

% where to place the eigenvalues of the closed-loop system
placed_eigenvals = 0.1;
%% lookup loaded dataset
nact = size(Uin, 1);
nmeas = size(Uin, 2);
apmask = dsspec.apmask;
assert(size(Yout, 1) == sum(apmask(:)));
assert(size(Yout, 2) == nmeas);
%% register aperture & select Zernike polynomials
zstruct = zernike_table(n_radial);
mimmaxphase = [min(Yout(:)), max(Yout(:))];
[zstruct, Yout, Zb, zapmask] = register_aperture(zstruct, Yout, apmask);
fprintf('zstruct.ncoeff = %d\n', zstruct.ncoeff);
%% compute H
[H, z0] = identify_H(Uin, Yout, Zb);
%% proportional feedback controller (use agressive dead beat?)
clc;

nz = size(H, 1);
nu = size(H, 2);
assert(nz >= nu);

% LTI system is observable but not controllable (can't control higher order
% Zernike modes
assert(nz >= nu);
[U, S, V] = svd(H);
sv = diag(S);

sfigure(1);
semilogy(diag(S), 'marker', 'o');
title('singular values');
grid on;

S11 = S(1:nu, 1:nu);
lambda = do_regularisation*sv(floor(tikhonov_filter_perc*numel(sv)));
% lambda = do_regularisation*sv(40);
tikhonov = diag(lambda^2*(ones(size(sv))./sv));
S1 = S11 + do_regularisation*tikhonov;
sfigure(50);
subplot(1, 2, 1);
semilogy(1:numel(sv), [sv, diag(S1)]);
grid on;
title(sprintf('tikhonov %.3f', lambda));
subplot(1, 2, 2);
plot(1:numel(sv), sv.^2./(sv.^2 + lambda^2));
hold on;
yl = ylim();
plot(lambda*ones(1, 2), yl, 'r--');
ylim(yl);
hold off;
grid on;
assert(rank(S) == nu);
Tinv = [inv(S1), zeros(nu, nz - nu); zeros(nz - nu, nu), eye(nz - nu)]*U';
T = U*[S1, zeros(nu, nz - nu); zeros(nz - nu, nu), eye(nz - nu)];
Inz = eye(nz);
% err = Inz - T*Tinv;
% assert(norm(err(:)) < 1e-9);
% err = Inz - Tinv*T;
% assert(norm(err(:)) < 1e-9);

A1 = eye(nz); % Tinv*eye(nz)*T
B1 = Tinv*H;
C1 = T; % CT

p = 1 - placed_eigenvals;
L1 = p*V;
A1full = eye(nz) - [V'*L1, zeros(nu, nz - nu); zeros(nz - nu, nz)];
e = eig(A1full);

dd = linspace(0, 2*pi, 100);
sfigure(3);
plot(cos(dd), sin(dd), 'r');
hold on;
plot(real(e), imag(e), 'x', 'markersize', 12, 'linewidth', 2);
grid on;

Lp = p*V*inv(S1)*U(:, 1:nu)';

% simulation
simlen = 10;
Phi0 = make_Phi(z0, zapmask, 1);
zhat0 = zernike_fit(zstruct, Phi0);

xk = reshape(zhat0(2:end), nz, 1);
xklog = zeros(nz, simlen);
rmslog = -inf*ones(1, simlen);

checkxk = xk;

for i=1:simlen
    xklog(:, i) = xk;
    rmslog(i) = norm(xk);

    sfigure(10);
    clf();
    subplot(2, 1, 1);
    plot(1:numel(xk), xk, 'marker', 'o');
    strehl = exp(-norm(xk).^2);
    title(sprintf('i=%d strehl=%.3f rms1=%.2f', i, strehl, rmslog(i)));
    xaxis = 2:(numel(xk) + 1);
    if numel(xaxis) > 7
        inds = 1:floor(numel(xaxis)/7):numel(xaxis);
        set(gca, 'XTick', inds, 'XTickLabel', xaxis(inds));
    else
        set(gca, 'XTick', 1:numel(zab));
    end
    grid on;
    subplot(2, 1, 2);
    plot(1:simlen, rmslog, 'marker', 'x');
    xlim([1, simlen]);
    grid on;
    ylabel('rms');
    xlabel('time');

    checkuk = -[p*V, zeros(nu, nz - nu)]*Tinv*xk;
    checkuk1 = -Lp*xk;
    checkxkp1 = checkxk + T*[V'; zeros(nz - nu, nu)]*checkuk;
    checkxk = checkxkp1;
    
    xhatk = Tinv*xk;
    uk = [-L1, zeros(nu, nz - nu)]*xhatk;
    xhatp1 = xhatk + [V'; zeros(nz - nu, nu)]*uk;
    
    % next iteration
    xk = T*xhatp1;

    % check
    fprintf('sim P i = %d\n', i);
    assert(norm(checkuk1 - uk) < 1e-10);
    assert(norm(checkuk - uk) < 1e-10);
    assert(norm(checkxk - xk) < 1e-10);

    pause(.1);
end

ssmatfile = sprintf('%s%sLp-%d-%d-%s.txt', ssmatrixdir, ...
    filesep(), size(Lp, 1), size(Lp, 2), ...
    datestr(now(), 'yyyy-mm-dd_HH-MM-SS'));
labview_write_matrix(ssmatfile, Lp);
fprintf('saved %s\n', ssmatfile);

