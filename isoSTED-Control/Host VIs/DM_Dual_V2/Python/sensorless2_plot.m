function [] = sensorless2_plot(priv)

zinds = 1:21;

allstacks = [priv.stack0(:); priv.stacks(:)];
clstacks = [min(allstacks(:)), max(allstacks(:))];

plot_mode(priv, 1);

    function callme(myh, ~, mypriv)
        myind = round(myh.Value);
        plot_mode(mypriv, myind);
    end
    function plot_mode(mypriv, myind)
        h = sfigure(1);
        clf();
        p = get(h, 'Position');
        p(3) = round(2*p(4));
        set(h, 'Position', p);
        u = mypriv.dm0s(:, myind);
        z = mypriv.dm0H1*(mypriv.dm0s(:, myind) - mypriv.u0flat);
        dm_plot(u, 2, 4, -1, 1);
        subplot(2, 4, 2);
        zernike_imagesc(mypriv.zplot0, z);
        axis equal;
        axis off;
        subplot(2, 4, 5);
        plot(z(zinds));
        legend(num2str(norm(z)));
        grid on;
        ylabel('[calib-rad 775]');
        xlabel('zernike');
        subplot(2, 4, 6);
        plot(u);
        grid on;
        xlabel('acts');
        
        u = mypriv.dm1s(:, myind);
        z = mypriv.dm1H1*(mypriv.dm1s(:, myind) - mypriv.u1flat);
        dm_plot(u, 2, 4, -1, 3);
        subplot(2, 4, 4);
        zernike_imagesc(mypriv.zplot1, z);
        axis equal;
        axis off;
        subplot(2, 4, 7);
        plot(z(zinds));
        grid on;
        legend(num2str(norm(z(2:end))));
        ylabel('[calib-rad 775]');
        xlabel('zernike');
        subplot(2, 4, 8);
        plot(u);
        grid on;
        xlabel('acts');
        
        if ~isempty(mypriv.metric_stacks)
            sfigure(4);
            clf();
            
            subplot(2, 2, 1);
            imagesc(reshape(...
                mypriv.stacks(:, myind), size(mypriv.stack0)), clstacks);
            axis equal;
            axis tight;
            axis off;
            colorbar();
            if myind == 1
                title('cur step: 0 (LabView DM settings)');
            else
                title(sprintf('cur step: %d', myind - 1));
            end
            
            subplot(2, 2, 2);
            imagesc(reshape(...
                mypriv.stacks(:, 2), size(mypriv.stack0)), clstacks);
            axis equal;
            axis tight;
            axis off;
            colorbar();
            if norm(mypriv.dm_aberratiom_rad) ~= 0
                title(sprintf('step 1: DM ab %.2f [rad775] %.2f [nm]', ...
                    norm(mypriv.dm_aberratiom_rad), ...
                    norm(mypriv.dm_aberratiom_nm)));
            else
                title('step 1: Python flat');
            end
            
            subplot(2, 2, 4);
            plot(mypriv.log_y);
            grid on;
            title('Raw metric');

            if myind > 1 && myind - 1 <= numel(mypriv.log_y)
                hold on;
                plot(myind - 1, mypriv.log_y(myind - 1), 'rx');
                hold off;

                subplot(2, 2, 3);
                imagesc(...
                    reshape(mypriv.metric_stacks(:, myind - 1), ...
                    size(mypriv.stack0)));
                axis equal;
                axis tight;
                axis off;
                colorbar();
            end
        end
        
        try
            sfigure(5);
            
            subplot(2, 2, 1);
            imagesc(mypriv.stack0, clstacks);
            axis equal;
            axis tight;
            axis off;
            title('step 0: LabView DM settings');
            colorbar();
            
            subplot(2, 2, 2);
            imagesc(reshape(...
                mypriv.stacks(:, 2), size(mypriv.stack0)), clstacks);
            axis equal;
            axis tight;
            axis off;
            if norm(mypriv.dm_aberratiom_rad) ~= 0
                title(sprintf('step 1: DM ab %.2f [rad775] %.2f [nm]', ...
                    norm(mypriv.dm_aberratiom_rad), ...
                    norm(mypriv.dm_aberratiom_nm)));
            else
                title('step 1: Python flat');
            end
            colorbar();

            subplot(2, 2, 3);
            imagesc(reshape(...
                mypriv.stacks(:, 3), size(mypriv.stack0)), clstacks);
            axis equal;
            axis tight;
            axis off;
            title('step 2: Python flat/DM aberrated + bias');
            colorbar();

            subplot(2, 2, 4);
            imagesc(reshape(...
                mypriv.stacks(:, end), size(mypriv.stack0)), clstacks);
            axis equal;
            axis tight;
            axis off;
            title(sprintf('step %d: After correction', ...
                size(mypriv.stacks, 2)));
            colorbar();
        catch
        end
        
        try
            if myind > 2 && myind < size(mypriv.stacks, 2)
                sfigure(6);
                clf();
                mysteps = size(mypriv.modal_xdata, 1);
                mymodei = floor((myind - 3)/mysteps) + 1;
                myfitind = rem(myind - 3, mysteps) + 1;
                myxdata = mypriv.modal_xdata(:, mymodei);
                myydata = mypriv.modal_ydata(:, mymodei);
                myyhat = mypriv.modal_yhat(:, mymodei);
                myxdata = mypriv.rad_to_nm*myxdata;
                plot(myxdata, [myydata, myyhat], 'Marker', 'o');
                grid on;
                hold on;
                plot(myxdata(myfitind), ...
                    [myydata(myfitind), myyhat(myfitind)], ...
                    'ro', 'MarkerSize', 12);
                hold off;
                legend('data', 'fit');
                title(sprintf('fit mode:%d/%d meas:%d/%d', mymodei, ...
                    size(mypriv.modal_xdata, 2), myfitind, ...
                    size(mypriv.modal_xdata, 1)));
                ylabel('Normalised metric');
                xlabel('aberration [nm]');
            elseif myind == 1
                sfigure(6);
                clf();
                title('LabView DM setting (no plot)');
            elseif myind == 2
                sfigure(6);
                clf();
                title('Python flat / DM aberrated (no plot)');
            elseif myind == size(mypriv.stacks, 2)
                sfigure(6);
                clf();
                title('Final correction (no plot)');
            else
                assert(0);
            end
        catch
        end
        
        h = sfigure(10);
        clf();
        p = get(h, 'Position');
        p(4) = 60;
        set(h, 'Position', p);
        uicontrol('Style', 'slider', ...
            'Units', 'normalized', ...
            'Position', [.1, .1, .8, .8], ...
            'Min', 1, ...
            'Max', size(priv.stacks, 2), ...
            'Value', myind, ...
            'SliderStep', ...
            [1/size(priv.stacks, 2), 1/size(priv.stacks, 2)], ...
            'Callback', {@callme, priv});
    end
end
