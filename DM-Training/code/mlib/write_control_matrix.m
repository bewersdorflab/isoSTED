function [] = write_control_matrix(controlmatrixdir, datasetname, ...
    nowvar, txt, C)
if ~exist('nowvar', 'var') || isempty(nowvar)
    nowvar = now();
end
if isempty(controlmatrixdir)
    controlmatrixdir = '.';
end
controlmatfile = sprintf('%s%sC-%s-%d-%d-%s-%s.txt', controlmatrixdir, ...
    filesep(), datasetname, size(C, 2), size(C, 1), ...
    datestr(nowvar, 'yyyy-mm-dd_HH-MM-SS'), txt);
labview_write_matrix(controlmatfile, C);
fprintf('saved %s\n', controlmatfile);
end
