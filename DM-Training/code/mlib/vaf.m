%MYVAF compute VAF row wise.
%
function [vaf] = vaf(y, ye)
vaf = max(0, max(100*(1 - var(y - ye, [], 2)/var(y, [], 2))));
end