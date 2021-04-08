clear;
clc;
% close all;

addpath('./mshwfs/');

% to extract data from the H5 file, see end of file

%% set a log file or automatically pick last one

% logfile = [];

% automatically pick last logfile
if ~exist('logfile', 'var') || isempty(logfile)
    list = dir('*.h5');
    if ~isempty(list)
        list2 = cell(1, length(list));
        for i=1:length(list)
            list2{i} = list(i).name;
        end
        list = sort(list2);
        clear list2;
        logfile = list{length(list)};
        clear list;
    end
end

% no file selected
assert(~isempty(logfile));

fprintf('Opening %s\n', logfile);

%% save last run arguments

% write arguments to txt file
args = h5read(logfile, '/args');
args = args{1};
fprintf('Configuration:\n%s\n\n', strrep(args, ', ', sprintf(',\n')));
fid = fopen('last_args.txt', 'wt');
fprintf(fid, '%s\r\n', strrep(args, ', ', sprintf(',\r\n')));
fclose(fid);

blob = struct();
%% load mirror calibration
load('./calibrations/13RW023p017/13RW023p017_ds1-351-88-matrices.mat');
dm0H1 = Hf;
dm0C1 = Cf;
dm0zs = zstruct2;
zplot0 = make_zplot(dm0zs);
load('./calibrations/13RW023p017/13RW023p017_params.mat');
u0flat = uflat;

load('./calibrations/13RW018p054/13RW018p054_ds1-351-88-matrices.mat');
dm1H1 = Hf;
dm1C1 = Cf;
dm1zs = zstruct2;
zplot1 = make_zplot(dm1zs);
load('./calibrations/13RW018p054/13RW018p054_params.mat');
u1flat = uflat;

blob.zplot0 = zplot0;
blob.zplot1 = zplot1;
blob.dm0H1 = dm0H1;
blob.dm1H1 = dm1H1;
blob.u0flat = u0flat;
blob.u1flat = u1flat;
%% load logfile
hinfo = hdf5info(logfile);

% read stacks
stack0 = hdf5read(logfile, '/input/stack/000000000')';
stacks = [];
dm0s = [];
dm1s = [];
i = 0;
run = 1;
while run
    try
        dset = hdf5read(logfile, sprintf('/input/stack/%09d', i))';
        stacks = [stacks, dset(:)];

        dset = hdf5read(logfile, sprintf('/output/dm0/%09d', i));
        dm0s = [dm0s, dset(:)];

        dset = hdf5read(logfile, sprintf('/output/dm1/%09d', i));
        dm1s = [dm1s, dset(:)];

        i = i + 1;
    catch
        run = 0;
        break
    end
end
initdms = hdf5read(logfile, '/initial/dms')';
dm0s = [initdms(:, 1), dm0s];
dm1s = [initdms(:, 2), dm1s];
blob.stacks = stacks;
blob.stack0 = stack0;
blob.dm0s = dm0s;
blob.dm1s = dm1s;
assert(size(stacks, 2) == size(dm0s, 2) - 1);
assert(size(stacks, 2) == size(dm1s, 2) - 1);

% read rings
rings = [];
rings_x = [];
ring0 = [];
i = 0;
run = 1;
try
    ring0 = hdf5read(logfile, sprintf('/metric/ring/%09d', 0))';
    while run
        dset = hdf5read(logfile, sprintf('/metric/ring/%09d', i))';
        rings = [rings, dset(:)];
        
        dset = hdf5read(logfile, sprintf('/metric/x/%09d', i));
        rings_x = [rings_x, dset(:)];
        
        i = i + 1;
    end
catch
    run = 0;
end
blob.rings = rings;
blob.rings_x = rings_x;
blob.ring0 = ring0;

% metric stacks
metric_stacks = [];
i = 0;
run = 1;
try
    while run
        dset = hdf5read(logfile, sprintf('/metric/stack/%09d', i))';
        metric_stacks = [metric_stacks, dset(:)];
        
        i = i + 1;
    end
catch
    run = 0;
end
blob.metric_stacks = metric_stacks;

% metric_FM
metric_FM = [];
i = 0;
run = 1;
try
    while run
        dset = hdf5read(logfile, sprintf('/metric/FM/%09d', i))';
        metric_FM = [metric_FM, dset(:)];
        
        i = i + 1;
    end
catch
    run = 0;
end
blob.metric_FM = metric_FM;
assert(isempty(metric_FM) || size(metric_FM, 2) == size(stacks, 2) - 1);

% modal
modal_xdata = [];
modal_ydata = [];
modal_yhat = [];
modal_popt = [];
try
	modal_fitter = hdf5read(logfile, '/modal/fitter');
	modal_func = hdf5read(logfile, '/modal/func');
	modal_initial = hdf5read(logfile, '/modal/initial');
	modal_name = hdf5read(logfile, '/modal/name');
catch
	modal_fitter = [];
	modal_func = [];
	modal_initial = [];
	modal_name = [];
end

i = 0;
run = 1;
try
    while run
        dset = hdf5read(logfile, sprintf('/modal/xdata/%09d', i));
        modal_xdata = [modal_xdata, dset(:)];
        dset = hdf5read(logfile, sprintf('/modal/ydata/%09d', i));
        modal_ydata = [modal_ydata, dset(:)];
        dset = hdf5read(logfile, sprintf('/modal/yhat/%09d', i));
        modal_yhat = [modal_yhat, dset(:)];
        dset = hdf5read(logfile, sprintf('/modal/popt/%09d', i));
        modal_popt = [modal_popt, dset(:)];
        
        i = i + 1;
    end
catch
    run = 0;
end
blob.modal_fitter = modal_fitter;
blob.modal_func = modal_func;
blob.modal_initial = modal_initial;
blob.modal_name = modal_name;
blob.modal_xdata = modal_xdata;
blob.modal_ydata = modal_ydata;
blob.modal_yhat = modal_yhat;
blob.popt = modal_popt;

log_x = hdf5read(logfile, 'log_x')';
log_y = -hdf5read(logfile, 'log_y');
assert(numel(log_y) == size(stacks, 2) - 1);
assert(size(log_x, 2) == size(stacks, 2) - 1);
blob.log_x = log_x;
blob.log_y = log_y;

% the Python code internally uses the radians defined by the wavelength
% used during the DM calibration (calibration_lambda=775nm). These radians
% can be converted to nm with rad_to_nm
try
	rad_to_nm = hdf5read(logfile, '/dmcontrol/rad_to_nm');
catch
	rad_to_nm = 1;
end
blob.rad_to_nm = rad_to_nm;

try
    dm_aberratiom_rad = hdf5read(logfile, 'dmcontrol/dm_ab_calib_rad');
    dm_aberratiom_nm = dm_aberratiom_rad*rad_to_nm;
    fprintf('DM aberration with RMS %.2f [rad 775], %.2f [nm]\n\n', ...
        norm(dm_aberratiom_rad), norm(dm_aberratiom_nm));
catch
    fprintf('No DM aberration info\n\n');
    dm_aberratiom_rad = hdf5read(logfile, 'dmcontrol/dm_ab_calib_rad');
    dm_aberratiom_nm = dm_aberratiom_rad*rad_to_nm;
end
blob.dm_aberratiom_rad = dm_aberratiom_rad;
blob.dm_aberratiom_nm = dm_aberratiom_nm;
%%
try
    zernike_indices = double(hdf5read(logfile, ...
        'dmcontrol/zernike_indices'))';
    all_4pi = double(hdf5read(logfile, 'dmcontrol/all_4pi'))';
    exclude_4pi = double(hdf5read(logfile, 'dmcontrol/exclude_4pi'))';
    rem_indices = double(hdf5read(logfile, 'dmcontrol/rem_indices'))' + 1;

    fprintf('Noll indices considered:\n%s\n', num2str(zernike_indices));
    fprintf('Available 4Pi modes:\n%s\n', num2str(all_4pi));
    fprintf('Exclude 4Pi modes:\n%s\n', num2str(exclude_4pi));
    fprintf('Used 4Pi modes:\n%s\n', num2str(all_4pi(rem_indices)));
catch
end
%% scrollable plot
plot_steps(blob);

%% to extract raw data

steps = (1:size(stacks, 2)) - 1;

% steps are:
% steps(1)=0: initial DM values set by LabView
% steps(2)=1: DM aberration by Python / real aberration
% steps(3)=2: DM aberration by Python + bias / real aberration + bias
% ...
% steps(end): aberration corrected

[dm0, dm1, img] = get_data(blob, steps(1));

% all returned dm0 and dm1 include u0flat and u1flat except for the first
% since it's set by LabView dm0_without_flat = dm0 - u0flat

% All DM values are normalised to [-1, 1], voltage300 = (dm0 + 1)/2*300.
% LabView uses PythonVoltage2Signal.vi to convert [-1, 1] to [0, 300] where
% the scaling is done by the fixed value 300 instead of the fixed value
% 3500! The [0, 300] value is then multiplied by (2^16 - 1)/300 and written
% to the DAQ by WriteDM_V2.vi (WRITE DATA MULTI 5.5). (This is, I believe,
% also what the MATLAB code did during calibration of the DMs.

% to save something for LabView use:
% labview_write_matrix('file.txt', dm0(:)')