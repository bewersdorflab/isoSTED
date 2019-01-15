function [] = test_control_matrix(what, zstruct, ...
    nocaxis, show_mm, mag, db)
if exist('plotdata_dmmodes.mat', 'file')
    if ~exist('show_mm', 'var') || isempty(show_mm)
        mmp = 1;
    else
        mmp = show_mm == 1;
    end
    
    if ~exist('db', 'var') || isempty(db)
        db = 50;
    end
    if ~exist('mag', 'var') || isempty(mag)
        mag = 1;
    end
    
    % NOTE lookup flips (dmplot_fliplr, dmplot_flipud in dm_modes.m) for
    % plotting the actuator layout
    
    % zplot is for plotting only
    zplot = make_zplot(zstruct);
    
    loopi = find(zstruct.selected_zernikes);
    
    priv = struct();
    priv.db = db;
    priv.zstruct = zstruct;
    priv.loopi = loopi;
    priv.mag = mag;
    priv.what = what;
    priv.nocaxis = nocaxis;
    priv.zplot = zplot;
    priv.mmp = mmp;

    plot_mode(priv, 1);

    uicontrol('Style', 'slider', ...
        'Units', 'normalized', ...
        'Position', [.2, .01, .6, .05], ...
        'Min', 1, 'Max', numel(loopi), 'Value', 1, ...
        'SliderStep', [1/numel(loopi), 1/numel(loopi)], ...
        'Callback', {@callme, priv});
end
    function callme(myh, ~, mypriv)
        myind = round(myh.Value);
        plot_mode(mypriv, myind);
    end
    function plot_mode(mypriv, myind)
        sfigure(mypriv.db);
        mytest = zeros(mypriv.zstruct.ncoeff, 1);
        mytest(mypriv.loopi(myind)) = mypriv.mag;
        
        if isa(mypriv.what, 'function_handle')
            myu = mypriv.what(mytest);
        else
            myu = mypriv.what*mytest;
        end
        
        dm_plot(myu, 2, 2, mypriv.mmp, 2, mypriv.nocaxis);
        subplot(2, 2, 3);
        zernike_imagesc(mypriv.zplot, mytest);
        axis equal;
        axis off;
        [~, ~, mynollstr, mynmstr] = zernike_Noll2nm(mypriv.zstruct, ...
            mypriv.loopi(myind));
        title([mynollstr, ' ', mynmstr, ...
            sprintf(' %.1f [rad]', mypriv.mag)], ...
            'Interpreter', 'Latex');
        subplot(2, 2, 4);
        plot(myu, 'Marker', '.');
        ylim([-1, 1]);
        grid on;
        if norm(myu, inf) >= 1
            title('SAT');
        else
            title('OK');
        end
    end
end
