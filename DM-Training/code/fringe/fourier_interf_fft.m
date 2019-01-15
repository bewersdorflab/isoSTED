% FOURIER_INTERF_FFT compute the Fourier transform of an interferogram.
%   [ABSLOGf, APMASK, N] = FOURIER_INTERF_FFT(FRINGES)
%   FRINGES         NN x NN square interferogram
%
% Author: Jacopo Antonello <jacopo.antonello@dpag.ox.ac.uk>
% Centre for Neural Circuits and Behaviour, University of Oxford

function [abslogF, apmask, N] = fourier_interf_fft(fringes)

[apmask, N] = fourier_apmask(fringes);

f = fringes(:, :, 1);

% zero out-of-aperture
f(~apmask) = 0;

f = fftshift(f); % shift to fftbase
F = fft2(f);
abslogF = fftshift(log(abs(F)));

end
