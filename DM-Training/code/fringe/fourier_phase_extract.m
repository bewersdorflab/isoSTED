% FOURIER_PHASE_EXTRACT extract the phase from an interferogram.
%   [PHI, APMASK] = FOURIER_PHASE_EXTRACT(FRINGES, FFTMASK, DB)
%   FRINGES         NN x NN x NFRAMES array of square interferograms
%   FFTMASK         square NN x NN mask to select the Fourier peak
%
%   PHI             extracted phase NN x NN x NFRAMES
%   APMASK          circular aperture mask
%
%   References:
%   [peck2010] M. Peck, "Interferometry mathematics, algorithms, and data"
%   <mpeck1@ix.netcom.com> February 10, 2010
%   home.earthlink.net/~mlpeck54/astro/imath/imath.pdf
%   [takeda1982] M. Takeda, H. Ina, and S. Kobayashi, "Fourier-transform
%   method of fringe-pattern analysis for computer-based topography and
%   interferometry," J. Opt. Soc. Am. 72, 156-160 (1982)
%   http://dx.doi.org/10.1364/JOSA.72.000156
%
% Author: Jacopo Antonello <jacopo.antonello@dpag.ox.ac.uk>
% Centre for Neural Circuits and Behaviour, University of Oxford

function [Phi, apmask] = fourier_phase_extract(fringes, fftmask, db)

[abslogF, apmask, N] = fourier_interf_fft(fringes(:, :, 1));
assert(size(fringes, 2) == N);
assert(ismatrix(fftmask));
assert(size(fftmask, 1) == N);
assert(size(fftmask, 2) == N);

nstack = size(fringes, 3);

Phi = -inf*ones(size(fringes));

for i=1:nstack
    f = fringes(:, :, i);

    % zero out-of-aperture
    %f(~apmask) = 0;

    f = fftshift(f); % shift to fftbase
    F = fft2(f);
    
    M = fftshift(fftmask); % shift to fftbase
    g0 = round(mgcentroid(fftmask)) - round(N/2);
    Fg = F.*M;
    % use g0(2); g0(1) due to meshgrid!
    Fg_sft = fftshift(circshift(fftshift(Fg), -[g0(2); g0(1)]));
    expiphi = fftshift(ifft2(Fg_sft));
    phi = atan2(imag(expiphi), real(expiphi));
    %phi(~apmask) = 0;
    Phi(:, :, i) = phi;

    if exist('db', 'var') && db > 0
        sfigure(db);
        clf();

        subplot(2, 3, 1);
        imagesc(fftshift(f));
        axis equal;
        axis off;
        title('f');

        subplot(2, 3, 2);
        imagesc(abslogF);
        axis equal;
        axis off;
        title('F=F[f]');

        subplot(2, 3, 3);
        imagesc(fftshift(M));
        axis equal;
        hold on;
        plot(round(N/2), round(N/2), 'g+', 'markersize', 11);
        plot(g0(1) + round(N/2), g0(2) + round(N/2), ...
            'rx', 'markersize', 11);
        hold off;
        axis off;
        title('M');

        subplot(2, 3, 4);
        imagesc(fftshift(log(abs(Fg))));
        hold on;
        plot(round(N/2), round(N/2), 'g+', 'markersize', 11);
        hold off;
        axis equal;
        axis off;
        title('F*M');

        subplot(2, 3, 5);
        imagesc(fftshift(log(abs(Fg_sft))));
        hold on;
        plot(round(N/2), round(N/2), 'g+', 'markersize', 11);
        hold off;
        axis equal;
        axis off;
        title('shifted');
    

        subplot(2, 3, 6);
        imagesc(phi);
        axis equal;
        axis off;
        title('\Phi');

        pause(1);
    end
end
assert(all(isfinite(Phi(:))));

    % Uses the meshgrid convention, not suitable for the MSHWFS toolbox.
    function [myret] = mgcentroid(myim, mythr)

        assert(isa(myim, 'double'));

        if (nargin < 2)
            mythr = 0;
        end
        
        [myn1, myn2] = size(myim);

        [myxx1, myxx2] = meshgrid(1:myn1, 1:myn2);
        myim(myim < mythr) = 0;
        mysum1 = sum(reshape(myxx1.*myim, numel(myxx1), 1));
        mysum2 = sum(reshape(myxx2.*myim, numel(myxx2), 1));
        mymass = sum(myim(:));

        myret = [mysum1/mymass, mysum2/mymass];
        
    end

end
