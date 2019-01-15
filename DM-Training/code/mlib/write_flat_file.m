function [] = write_flat_file(flatfiledir, datasetname, nowvar, txt, u)
if ~exist('nowvar', 'var') || isempty(nowvar)
    nowvar = now();
end
if isempty(flatfiledir)
    flatfiledir = '.';
end
flatfile = sprintf('%s%sflat-%s-%s-%s.txt', flatfiledir, ...
    filesep(), datasetname, datestr(nowvar, 'yyyy-mm-dd_HH-MM-SS'), txt);
labview_write_matrix(flatfile, reshape(u, 1, numel(u)));
fprintf('saved %s\n', flatfile);
end
