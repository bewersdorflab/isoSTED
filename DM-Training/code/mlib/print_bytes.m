% clc;
s = whos();

nbytes = zeros(length(s), 1);
nnames = cell(length(s), 1);
for i=1:length(s)
    nbytes(i) = s(i).bytes;
    nnames{i} = s(i).name;
end
[~, inds] = sort(nbytes);

for i=1:length(s)
    fprintf('%s\t%s\n', ...
        bytes2str(nbytes(inds(i))), nnames{inds(i)});
end

clear s nbytes nnames inds;