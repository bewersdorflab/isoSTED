% COMPUTE_HIGH_NA_HFZ.
%
%   TODO
%   defocus is in rad
%   add ref torok1995c
%
% Author: Jacopo Antonello <jacopo.antonello@dpag.ox.ac.uk>
% Centre for Neural Circuits and Behaviour, University of Oxford

function [zc, sinds, smap] = highNAdefocus2zernike(def, zstruct, NA, n)

sinalpha = NA/n;
c = 2/(sinalpha^2) - 1;
jnm = zstruct.jtonmtable;
nz = size(jnm, 1);
smap = jnm(:, 2) == 0;
sinds = find(smap);
nsph = numel(sinds);

zc = zeros(nz, 1);
zc(smap == 1) = compute_Kc();

    function myKc = compute_Kc()
        myKc = zeros(nsph, 1);
        for myk=0:(nsph - 1)
            myTorokKc = (-sqrt(2)/((2*myk - 1)*(2*myk + 1))).* ...
                (1/((c + sqrt(c^2 - 1)).^(myk - 1/2))).* ...
                (1 - (2*myk - 1)/(2*myk + 3)*(1/((c + sqrt(c^2 - 1)).^2)));
            myKc(myk + 1) = -n*def*sqrt(2*myk + 1)*...
                sinalpha/(2*sqrt(2))*myTorokKc;
        end
    end
end
