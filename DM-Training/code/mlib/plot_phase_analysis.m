function [rms, maxPhi, minPhi, rmslambda, strehl, h] = ...
    plot_phase_analysis(Phi, apmask, txt)

if exist('txt', 'var')
    txt2 = [txt, ' '];
else
    txt2 = '';
end

Phi(apmask) = Phi(apmask) - mean(Phi(apmask));
Phi(~apmask) = -inf;

h = imagesc(Phi);
set(h, 'AlphaData', apmask);
axis equal;
axis off;
% surf(Phi);
% set(gca, 'YDir', 'Normal');
% shading interp;
h = colorbar;
axis equal;
axis off;
ylabel(h, '[rad]');
view(2);

rms = sigrms(Phi, apmask);
maxPhi = max(Phi(apmask));
minPhi = min(Phi(apmask));
pvlambda = (maxPhi - minPhi)/(2*pi);
rmslambda = rms/(2*pi);
strehl = exp(-rms.^2);
h = title(sprintf(...
    '%srms:%.2frad,%.2flmbd S:%.2f [%.2f, %.2f], PV:%.2flmbd', ...
    txt2, rms, rmslambda, strehl, minPhi, maxPhi, pvlambda));

end
