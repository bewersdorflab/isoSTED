clear;
close all;
clc;

addpath('./mlib/');

load testdata.mat;
%%
plot_delay = .1;

% selmeas = 233:280;
selmeas = 1:size(Yout, 2);
for i=selmeas
    Phi = make_Phi(Yout(:, i), dsspec.apmask);
    
    sfigure(1);

    subplot(2, 2, 1);
    plot_Phi(Phi, dsspec.apmask);
    title(num2str(i));

    subplot(2, 2, 2);
    plot(Uin(:, i), 'marker', '.');
    ylim([-1, 1]);

    dm_plot(Uin(:, i), 2, 2, 3, 4);
    
    pause(plot_delay);
end


