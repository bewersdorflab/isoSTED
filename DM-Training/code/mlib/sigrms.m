% sigrms(w, mask) computes the rms of a signal or surface.
%   y = sigrms(w, mask).
%   w               signal, mean value and nans are ignored
%   mask            use only w(mask) ~= 0
%
%   This is actually the std of the signal.
function y = sigrms(w, mask)
maskfinite = isfinite(w);
if exist('mask', 'var') && ~isempty(mask)
    mask = logical(maskfinite.*mask);
else
    mask = logical(maskfinite);
end
w = w(mask) - mean(w(mask));
y = sqrt((1/numel(w))*sum(w.^2));
end