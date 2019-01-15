function [image, dims, pxsize] = readDBL(filename)
% Read a DBL file and get the image back
% images have 128 byte headers

fid = fopen(filename, 'r');

pxsize = fread(fid, 4, 'uint16', 'b');
dims = fread(fid, 4, 'single', 'l');
fseek(fid, 128, -1);

image = fread(fid, [pxsize(3), pxsize(2)], 'uint16', 'l');

fclose(fid);