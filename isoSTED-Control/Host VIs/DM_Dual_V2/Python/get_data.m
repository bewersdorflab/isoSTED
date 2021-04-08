function [dm0, dm1, img] = get_data(blob, step0)

step = step0 + 1;

% NB: any value beyond size(blob.stacks, 2) is not used!
assert(step <= size(blob.stacks, 2));

dm0 = blob.dm0s(:, step);
dm1 = blob.dm1s(:, step);
img = reshape(blob.stacks(:, 1), size(blob.stack0));

end