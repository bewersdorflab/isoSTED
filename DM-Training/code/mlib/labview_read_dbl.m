function M = labview_read_dbl(fname)
M = readDBL(fname)';
% or use image files, e.g.,
% M = double(imread(fname));
end
