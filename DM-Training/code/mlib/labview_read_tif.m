function M = labview_read_tif(fname)
% M = readDBL(fname)';
% or use image files, e.g.,
buffer = loadcamtiff(fname, 'Mode', 'both', 'Info', 'all');
M = buffer.image;
end
