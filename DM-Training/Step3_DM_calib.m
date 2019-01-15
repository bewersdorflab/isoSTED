% STEP 3
% Generate new flat map and control matrix, updated from Jacopo's program

global par;

projectName = '13RW018#054';

addpath('.\code\mlib\');
addpath('.\code\fringe\');
addpath('.\code\mshwfs\');
addpath('.\code\modelling\');

% add external toolboxes
addpath_ext();

% Perform DM calibration using a dataset. A dataset may be generated using
% the modelling scripts (modelling/*.m) or by reading out experimental
% measurements (defined by the 'datasetpath').

% Computes the influence matrix H1 and the control matrix C. Vector u
% contains the voltage values normalised between [-1, 1] of each actuator
% of the DM. Vector z contains the coefficients of the Zernike polynomials.
% Matrix H1 maps an actuation vector u into the corresponding vector of
% Zernike coefficients z=Hu. H1 can be estimated with a calibration
% experiment using a set of input voltages to the DM and the output phase
% profiles that measured with fringe analysis or a Shack-Hartmann sensor.
% Matrix C maps a given vector of Zernike coefficients z to the
% corresponding values of the DM actuators. It is computed by numerically
% inverting matrix H1.

% NB: both Uin and Yout should contain absolute measurements and not be
% relative to a reference! Uin(:, i) = 0 should correspond to the DM at
% its rest position (all actuators at rest or in a biased position), and
% Yout(:, i) should correspond to the absolute phase measured with an
% interferogram or a Shack-Hartmann.

% remove out-of-aperture actuators with low influence, can only be set as 0
% or 1. For 1, out of aperture actuators are ignored; for 0, they are
% considered.
ignore_out_of_aperture = 1;

% cut aperture by a factor, can only be set as 1
cut_aperture_factor = 1;

% use up to n_radial radial order Zernike polynomials
n_radial = 20;

% exclude Zernike polynomials (Noll's index)
exclude_zernike_indeces = [];

% % EXAMPLE 1 (bmcmultidm140, without piston)
% datasetpath = 'data_with_piston_20160719_converted';
% exclude_piston = 1; % fully ignore piston mode for all phase measurements

% EXAMPLE 2 (bmcmultidm140, with piston)reference_intef_image
folderName = [projectName '_calib_3_2016Sep06_18_13_38'];
newDir = ['.\DM data\' 'result\' folderName '\size=' num2str(par.apertureSize) ...
    '_shift_x=' num2str(par.aperture_shift_x) '_shift_y=' num2str(par.aperture_shift_y)];
datasetpath = [newDir '\poke data_converted.mat'];
exclude_piston = 0;

load(datasetpath);
[~, datasetname] = fileparts(datasetpath);

% high NA parameters
highNA = struct();

highNA.n = 1.406;
highNA.NA = 1.35;
highNA.lambda_calib = calibration_lambda;
highNA.lambda_use = calibration_lambda;

% output flat file & control matrix
mkdir([newDir '\control matrix and flatmap\']);
flatfiledir = [newDir '\control matrix and flatmap\'];
controlmatrixdir = [newDir '\control matrix and flatmap\'];;

%% lookup loaded dataset
nact = size(Uin, 1);
nmeas = size(Uin, 2);
apmask = dsspec.apmask;
assert(size(Yout, 1) == sum(apmask(:)));
assert(size(Yout, 2) == nmeas);

%% pre-process dataset
[Yout, apmask] = cut_aperture(Yout, apmask, cut_aperture_factor);
if exclude_piston
    assert(sum(any(exclude_zernike_indeces - 1)) == 0);
else
    Yout = fix_principal_val(Uin, Yout, calibration_lambda, 1);
end
if ignore_out_of_aperture
    [Uin, Yout, selected_acts] = exclude_out_of_aperture(Uin, Yout, ...
        2*pi/20, 2);
else
    selected_acts = logical(ones(nact, 1));
end

%% register aperture & select Zernike polynomials
zstruct = zernike_table(n_radial);
fprintf('Zernike polynomials: %d\n', zstruct.ncoeff)
mimmaxphase = [min(Yout(:)), max(Yout(:))];
[zstruct, Yout, Zb, zapmask] = register_aperture(zstruct, Yout, apmask);
assert(all(isfinite(Yout(:))));
zstruct = select_zernike_indeces(zstruct, exclude_zernike_indeces);
zstruct.selected_acts = selected_acts;

%% compute H1
if exclude_piston
    [Yout, z0] = remove_initab(Yout);
    Yout = remove_piston(Yout);
    [H1, ~, en, mvaf, ren, condA] = identify_H(Uin, Yout, ...
        Zb(:, zstruct.selected_zernikes));
else
    [H1, z0, en, mvaf, ren, condA] = identify_H(Uin, Yout, ...
        Zb(:, zstruct.selected_zernikes));
end

%% plots for H1
fprintf('cond(zH) = %g\n', cond(H1));
fprintf('max(z0) = %g\n', max(z0));
try
    fprintf('en = %g\n', en);
    fprintf('ren = %g\n', ren);
    fprintf('condA = %g\n', condA);
catch
end

sfigure(10);
semilogy(svd(H1), 'marker', '.');
grid on;
title(sprintf('cond(H1) = %g', cond(H1)));
pause(.1);

sfigure(11);
if exist('mvaf', 'var')
    subplot(2, 2, 1);
    boxplot(mvaf(:));
    title('phase fit quality');
    ylabel('fit [%]');
    grid on;
    pause(.1);
end

subplot(2, 2, 2);
Phi0 = make_Phi(z0, zapmask, 1);
zc0 = zernike_fit(zstruct, Phi0);
plot_Phi(Phi0, zapmask);
title(['$\Phi$', sprintf(' %.2f rms', sigrms(Phi0, zapmask))], ...
    'interpreter', 'latex');

subplot(2, 2, 3);
zernike_imagesc(make_zplot(zstruct), zc0);
colorbar();
axis equal;
axis off;
title(['$\Phi=\sum Z_i$', sprintf(' %.2f rms', norm(zc0(2:end)))], ...
    'interpreter', 'latex');

subplot(2, 2, 4);
xaxis = 1:numel(zc0);
plot(xaxis, zc0, 'marker', '.');
rms1 = norm(zc0(2:end));
strehl = exp(-rms1.^2);
title(sprintf('strehl %.3f rms1 %.2f', strehl, rms1));
if numel(xaxis) > 7
    inds = 1:floor(numel(xaxis)/7):numel(xaxis);
    set(gca, 'XTick', inds, 'XTickLabel', xaxis(inds));
else
    set(gca, 'XTick', 1:numel(zc0));
end
xlim([1, numel(zc0)]);
grid on;

% full matrix
Hf = zeros(zstruct.ncoeff, nact);
Hf(zstruct.selected_zernikes, zstruct.selected_acts) = H1;

%% find initial aberration correction (flattening)
% u_flat_l_inf = solve_Hf_linf(Hf, zc0, .7, zstruct);
u_flat_ls = solve_Hf_ls(Hf, zc0, zstruct);

%% generate flat file
if ~isempty(flatfiledir)
    mywriteflat = @(t, u) write_flat_file(flatfiledir, datasetname, ...
        now(), t, u);
%     mywriteflat('linf', u_flat_l_inf);
    mywriteflat('ls', u_flat_ls);
end

%% plot initial aberration of the DM
sfigure(20);
plot_phase_analysis(Phi0, zapmask);
sfigure(21);
plot_zernike_analysis(zstruct, Phi0);

sfigure(22);
% subplot(2, 1, 1);
% plot(u_flat_l_inf);
% hold on;
% plot([1, numel(u_flat_l_inf)], [1, 1], 'r');
% plot([1, numel(u_flat_l_inf)], -[1, 1], 'r');
% hold off;
subplot(2, 1, 2);
plot(u_flat_ls);
hold on;
plot([1, numel(u_flat_ls)], [1, 1], 'r');
plot([1, numel(u_flat_ls)], -[1, 1], 'r');
hold off;

%% save H
% save(sprintf('%s-%d-%d-H.mat', datasetname, size(H1, 1), size(H1, 2)), ...
%     'datasetpath', 'n_radial', ...
%     'nact', 'nmeas', 'apmask', 'zapmask', 'zstruct', 'H1', 'Hf', 'z0', ...
%     'Phi0', 'zc0');
%% compute plain control matrix C

% regularisation code is in (state_feedback_P.m)
C1 = pinv(H1);
Cf = zeros(nact, zstruct.ncoeff);
Cf(zstruct.selected_acts, zstruct.selected_zernikes) = C1;

sfigure(30);
semilogy(svd(C1), 'marker', '.');
grid on;
title(sprintf('cond(C1) = %g', cond(C1)));

% Cf can be used with the following control law in LabView
% u_{k + 1} = u_k - Cf*z_k
% u_k is vector of absolute voltages at time k
% z_k is the vector of zernike coefficients (first is tip, not piston) of
% the absolute phase

Cf_LabVIEW = Cf(:,1:140);   % we only concern about the first 140 modes.

if ~isempty(controlmatrixdir)
    mywriteflat = @(t, C) write_control_matrix(controlmatrixdir, ...
        datasetname, now(), t, C);
    mywriteflat('noreg', Cf_LabVIEW);
end
%% test plain control matrix Cf

% Note: some signs are swapped between the actuator layout and the mirror
% modes. This is due to the fact that the SVD does not have unique left and
% right singular vectors.

mag = 1;
f = 90;
show_mm = -1;
nocaxis = 1;
test_control_matrix(Cf, zstruct, nocaxis, show_mm, mag, f);

%% compute high NA control matrix C
hnaHf1 = compute_high_NA_H(H1, zstruct, highNA.NA, highNA.n, ...
    highNA.lambda_calib, highNA.lambda_use);

hnaC = pinv(hnaHf1);
hnaCf = zeros(nact, zstruct.ncoeff);
hnaCf(zstruct.selected_acts, zstruct.selected_zernikes) = hnaC;
hnaCf_LabVIEW = hnaCf(:,1:140);   % we only concern about the first 140 modes.

if ~isempty(controlmatrixdir)
    mywriteflat = @(t, C) write_control_matrix(controlmatrixdir, ...
        datasetname, now(), t, C);
    mywriteflat('noregHighNA', hnaCf_LabVIEW);
end

%% test high NA control matrix hnaC

% Note: some signs are swapped between the actuator layout and the mirror
% modes. This is due to the fact that the SVD does not have unique left and
% right singular vectors.

mag = 1;
f = 95;
show_mm = -1;
nocaxis = 1;
test_control_matrix(hnaCf, zstruct, nocaxis, show_mm, mag, f);

%% save control matrix
flat_map_1=u_flat_ls;
mask = par.mask;
save([newDir '\control matrix and flatmap\control matrix.mat'],'Cf_LabVIEW','hnaCf_LabVIEW','mask');
%save('flat_map_1_20160723.mat','flat_map_1');
