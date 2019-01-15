% IDENTIFY_H compute a Zernike influence matrix.
%   [H, Z0, EN, MVAF, REN, CONDA] = IDENTIFY_H(UIN, YOUT2, ZB).
%   Uin             Uin(:, i) contains the NACT voltage values normalised
%                   between [-1, 1]. Uin(k, i) corresponds to the k-th
%                   actuator.
%   Yout2           Yout2(:, i) contains the phase profile measured after
%                   applying Uin(:, i) with the DM. Yout2(:, i) only
%                   contains the phase values inside the aperture. If
%                   apmask is the phase mask indicating the aperture and
%                   [n1, n2] = size(apmask), use tmp = zeros(n1, n2),
%                   tmp(apmask) = Yout2(:, i), and imagesc(tmp) to see the
%                   phase profile.
%   Zb              Base of Zernike polynomials evaluated in the aperture.
%
%   H               matrix H, so that z \approx H u.
%   z0              phase profile for the initial aberration of the DM,
%                   which corresponds to zero actuation (all the actuators
%                   are at rest)
%   en              norm of the fit error
%   ren             relative norm of the fit error
%   condA           condition number of uiuiT, should be close to 1 and
%                   depends on Uin
%
%   Matrix H maps an actuation vector u (NACT voltage values normalised
%   between [-1, 1]) to a vector of Zernike coefficients (excluding the
%   piston mode), so that z=H*u.
%
%   See Eq.(3) and Eq.(4) in [antonello2014].
%
%   Example:
%   n_radial = 7; % choose up to 7th order Zernike polynomials
%   [Yout, zstruct, apmask, Zb] = find_aperture(apmask, ...
%       Yout, zernike_table(n_radial));
%   [H, z0] = identify_H(Uin, Yout, Zb);
%
%   References:
%   [antonello2014] J. Antonello, T. van Werkhoven, M. Verhaegen, H.
%   Truong, C. Keller, and H. Gerritsen, "Optimization-based wavefront
%   sensorless adaptive optics for multiphoton microscopy," J. Opt. Soc.
%   Am. A 31, 1337-1347 (2014)
%   doi: 10.1364/JOSAA.31.001337
%
% Author: Jacopo Antonello, <jack@antonello.org>
% Technische Universiteit Delft
% Sat Sep 28 09:24:40 UTC 2013
function [H, z0, en, mvaf, ren, condA] = identify_H(Uin, Yout2, Zb)
[inds, ~, z0, Yd, Ud] = dt(Uin, Yout2);
Y10 = Yout2(:, inds);

nu = size(Ud, 1);
nz = size(Yd, 1);
l = size(Yd, 2);

uiuiT = zeros(nu, nu);
phiiuiT = zeros(nz, nu);
for i=1:l
    uiuiT = uiuiT + Ud(:, i)*Ud(:, i)';
    phiiuiT = phiiuiT + Yd(:, i)*Ud(:, i)';
end
if exist('Zb', 'var') && ~isempty(Zb)
    H = ((Zb'*Zb)\(Zb'*phiiuiT))/(uiuiT);
    if nargout > 2
        Y1e = Zb*H*Ud + kron(ones(1, l), z0);
    end
else
    H = phiiuiT/uiuiT;
    if nargout > 2
        Y1e = H*Ud + kron(ones(1, l), z0);
    end
end

if nargout > 2
    er = Y10 - Y1e;
    
    mvaf = zeros(1, nz);
    for i=1:nz
        mvaf(i) = vaf(Y10(i, :), Y1e(i, :));
    end
    
    en = norm(er);
    ren = en/norm(Y10);
    condA = cond(uiuiT);
    fprintf('cond(A) %g\n', condA);
end

    function [myinds, myu0, myy0, myYd, myUd] = dt(myU1, myY1)
        myl = size(myY1, 2);
        mynorms = sum(myU1.^2, 1);
        myzrs = find(mynorms == 0);
        
        if isempty(myzrs)
            myu0 = mean(myU1, 2);
            myy0 = mean(myY1, 2);
            myinds = 1:myl;
        else
            myu0 = mean(myU1(:, myzrs), 2);
            myy0 = mean(myY1(:, myzrs), 2);
            myinds = setdiff(1:myl, myzrs);
        end
        
        myYd = myY1(:, myinds) - kron(ones(1, numel(myinds)), myy0);
        myUd = myU1(:, myinds) - kron(ones(1, numel(myinds)), myu0);
        
        % if ~isempty(myzrs)
        %     sfigure(15);
        %     clf;
        %     ny = size(myYd, 1);
        %     m1 = mean(myY1(:, myzrs), 2);
        %     m2 = std(myY1(:, myzrs), [], 2);
        %     m3 = std(myY1(:, myinds), [], 2);
        %     plot(1:ny, m1, 'Marker', 'o');
        %     hold on;
        %     plot(1:ny, m2, 'r', 'Marker', 'o');
        %     plot(1:ny, m3, 'g', 'Marker', 'o');
        %     hold off;
        %     legend('mean 0', 'std 0', 'std ~= 0');
        %     title('variations in zero');
        %     grid on;
        % end

    end
end
