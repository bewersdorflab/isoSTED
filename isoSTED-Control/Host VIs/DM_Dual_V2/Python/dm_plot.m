function [] = dm_plot(u, mm1, nn1, sp11, sp22, nocaxis)

if ~exist('nocaxis', 'var') || isempty(nocaxis)
    nocaxis = 0;
end
if ~exist('mm1', 'var') || isempty(mm1)
    mm1 = 1;
end
if ~exist('nn1', 'var') || isempty(nn1)
    nn1 = 2;
end
if ~exist('sp11', 'var') || isempty(sp11)
    sp11 = 1;
end
if ~exist('sp22', 'var') || isempty(sp22)
    sp22 = 2;
end

load plotdata_dmmodes.mat;

if sp11 > 0
    subplot(mm1, nn1, sp11);
    tmp = make_Phi(U2*V'*u, apmaskrs, 1);
    % if dmplot_fliplr
    %     tmp = fliplr(tmp);
    % end
    % if dmplot_flipud
    %     tmp = flipud(tmp);
    % end
    % tmp = zeros(n1rs, n2rs);
    % tmp(apmaskrs) = U2*V'*u;
    h = imagesc(tmp);
    set(h, 'AlphaData', apmaskrs);
    h = colorbar();
    ylabel(h, '[rad]');
    % imagesc(tmp, [min(U2(:)), max(U2(:))]);
    title('mirror modes');
    axis equal;
    axis off;
    axis tight;
end

if sp22 > 0
    subplot(mm1, nn1, sp22);
    if dmplot_fliplr
        xact = -xact;
    end
    if dmplot_flipud
        yact = -yact;
    end
    trisurf(tri, xact, yact, ...
        reshape(kron(ones(grow), u), numel(xact), 1));
    shading interp;
    view(2);
    h = colorbar();
%     ylabel(h, 'act');
    if ~nocaxis
        caxis([-1, 1]);
    end
    title(sprintf('acts [%.1f %.1f]', min(u), max(u)));
    axis equal;
    axis off;
    axis tight;
end
end
