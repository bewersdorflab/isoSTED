function [] = addpath_ext()
% read TIFF with float payload
if exist('./code/ext/CamTiff/', 'file')
    addpath(merge(pwd(), 'code/ext/cvx/keywords'));
end
% CVX
if exist('./code/ext/cvx/', 'file')
    addpath(merge(pwd(), 'code/ext/cvx/keywords'));
    addpath(merge(pwd(), 'code/ext/cvx/sets'));
    addpath(merge(pwd(), 'code/ext/cvx'));
    addpath(merge(pwd(), 'code/ext/cvx/functions/vec_'));
    addpath(merge(pwd(), 'code/ext/cvx/structures'));
    addpath(merge(pwd(), 'code/ext/cvx/lib'));
    addpath(merge(pwd(), 'code/ext/cvx/functions'));
    addpath(merge(pwd(), 'code/ext/cvx/commands'));
    addpath(merge(pwd(), 'code/ext/cvx/builtins'));
else
    fprintf('CVX not installed in ext/\n');
end
    function so = merge(s1, s2)
        so = sprintf('%s%s%s', s1, filesep(), s2);
    end
end
