function [Yout2] = fix_principal_val(Uin, Yout, lambda, db)

nms = size(Yout, 2);
Ym1 = mean(Yout);

% find points with zero actuation (mirror at rest)
norms = sqrt(sum(Uin.^2, 1));
inds = norms == 0;
nodes0 = Ym1(1, inds);

% measurements must be taken symmetrically around zero, e.g., scan each
% actuator using [-.5, 0, .5], otherwise it's not possible to determine the
% the piston influence function
assert(~isempty(nodes0));

nodes1 = unwrap(nodes0);

xx = 1:nms;
pistdist = interp1(xx(inds), nodes1, xx, 'spline');
assert(all(isfinite(pistdist(:))));

Ym2 = zeros(size(Ym1));
for i=1:nms
    k = round((pistdist(i) - Ym1(i))/(2*pi));
    Ym2(i) = Ym1(i) + 2*k*pi - pistdist(i);
end
maxdelta_rad = max(abs(diff(Ym2)));
maxdelta_lambda = maxdelta_rad/(2*pi);
maxdelta_nm = maxdelta_lambda*lambda/1e-9;
fprintf('%s: maxdelta_rad = %.2f\n', mfilename(), maxdelta_rad);
fprintf('%s: maxdelta_nm = %.2f (lambda %.2f nm)\n', mfilename(), ...
    maxdelta_nm, lambda/1e-9);
fprintf('%s: maxdelta_lambda = %.2f (should be << 1)\n', mfilename(), ...
    maxdelta_lambda);
% assert(maxphasestep < .8);

% apply piston correction
Yout2 = Yout + kron(ones(size(Yout, 1), 1), Ym2 - Ym1);

if exist('db', 'var') && db > 0
    sfigure(db);
    
    subplot(2, 2, 1);
    plot_principal_branch(nodes0);
    title('piston (nodes)');
    
    subplot(2, 2, 2);
    plot_principal_branch(nodes1);
    title('piston (nodes, unwrapped)');
    
    subplot(2, 2, 3);
    plot_principal_branch(mean(Yout));
    title('raw piston (all meas)');

    subplot(2, 2, 4);
    plot_principal_branch(mean(Yout2));
    title('fixed piston (all meas)');
end

    function plot_principal_branch(myv2)
        myv = myv2/(2*pi);
        plot(myv);
        myminv = min(myv);
        mymaxv = max(myv);
        hold on;
        plot([1, numel(myv)], -.5*[1, 1], 'r');
        plot([1, numel(myv)], .5*[1, 1], 'r');
        ylim([min([myminv, -.5]), max([mymaxv, .5])]);
        xlim([1, numel(myv)]);
        hold off;
        grid on;
        ylabel('[lambda]');
    end
end
