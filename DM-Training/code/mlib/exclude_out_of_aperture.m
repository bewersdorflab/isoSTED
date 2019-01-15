function [Uin, Yout, selected_acts, selected_meas] = ...
    exclude_out_of_aperture(Uin, Yout, thresh_rad, db)
Yrs = remove_initab(Yout);
Yrs = remove_piston(Yrs);

Ystd = std(Yrs, [], 1);
selected_meas = logical(Ystd > thresh_rad);

selected_acts = logical(sum(abs(Uin(:, selected_meas)), 2));
Uin = Uin(selected_acts, selected_meas);
Yout = Yout(:, selected_meas);

if db > 0
    sfigure(db);
    subplot(2, 2, 1:2);
    semilogy(1:numel(Ystd), Ystd);
    hold on;
    semilogy([1, numel(Ystd)], thresh_rad*[1, 1], 'r');
    hold off;
    xlabel('# meas');
    ylabel('[rad]');
    legend('std')
    title(sprintf('%.2f rad (%.2f lambda)', thresh_rad, ...
        thresh_rad/(2*pi)));
    grid on;
    try
        dm_plot(selected_acts, 2, 2, -1, 3);
    catch
    end
end
end