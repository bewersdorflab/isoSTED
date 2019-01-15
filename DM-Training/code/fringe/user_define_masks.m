function masks = user_define_masks(image_full, mask_fun, ...
    fringe_mask_size, reference_intef)

if exist('./last_masks.mat', 'file')
    load('./last_masks.mat');
else
    last_masks = [];
end

% fringe_mask_size must be even
% TODO fix round/ceil/floor in loading masks from pngs
if rem(fringe_mask_size, 2) == 1
    fringe_mask_size = fringe_mask_size - 1;
end
assert(ismatrix(image_full));
cross_fft_mask = [];
cross_fringe_mask = [];

while 1
    fprintf('*** APERTURE MASK\n');
    if exist('reference_intef', 'var') && ~isempty(reference_intef)
        [inds1, inds2, apmask apbox] = define_pupil(reference_intef);
    else
        [inds1, inds2, apmask, apbox] = define_pupil(image_full);
    end
    fprintf('(a) Hit "r" then "Enter" to repeat\n');
    fprintf('(b) Hit "Enter" to continue\n');
    str = input('USER INPUT: ', 's');
    if isempty(str)
        break;
    end
    fprintf('\n');
end

while 1
    fprintf('*** FFT MASK\n');
    fringes = image_full(inds1, inds2);
    [fftmask, fftbox] = define_fftmask(fringes);
    [Phi1, apmask1] = fourier_phase_extract(fringes, fftmask, 4);
    fprintf('(a) Hit "r" then "Enter" to repeat\n');
    fprintf('(b) Hit "Enter" to continue\n');
    str = input('USER INPUT: ', 's');
    if isempty(str)
        break;
    end
    fprintf('\n');
end

masks = struct();
masks.inds1 = inds1;
masks.inds2 = inds2;
masks.apmask = apmask;
masks.apbox = apbox;

masks.fftmask = fftmask;
masks.fftbox = fftbox;
masks.Phi1 = Phi1;
assert(norm(apmask(:) - apmask1(:)) == 0);
masks.nsupp = sum(apmask(:));
masks.image_full = image_full;

last_masks = masks;
save('./last_masks.mat', 'last_masks');

    function [myi1, myi2, apm, mybox] = define_pupil(mypf)
        figure(1);
        clf();
        imagesc(mypf);
%         imwrite((1/max(mypf(:)))*mypf, 'masks1.png');
        axis equal;
        
        try
            mylastfringes = mypf(last_masks.inds1, last_masks.inds2);
        catch
            mylastfringes = [];
        end
        if ~isempty(last_masks) && ~isempty(mylastfringes) && ...
                size(last_masks.apmask, 1) == size(mylastfringes, 1) && ...
                size(last_masks.apmask, 2) == size(mylastfringes, 2) && ...
                numel(last_masks.apmask) == numel(mylastfringes)
            mybox = last_masks.apbox;
            myhr = imrect(gca(), mybox);
        else
            myhr = imrect(gca(), ...
                [10, 10, fringe_mask_size, fringe_mask_size]);
        end
        setFixedAspectRatioMode(myhr, 1);
        addNewPositionCallback(myhr, @plot_centre_fringe_mask);
        setPositionConstraintFcn(myhr, ...
            makeConstrainToRectFcn('imrect', get(gca,'XLim'), ...
            get(gca,'YLim')));
        fprintf('Double click in the rectangle to accept\n');
        wait(myhr);
        pause(.5);
%         fprintf('Position a rectangle that circumscribes the aperture\n');
%         fprintf('(a) Hit "Enter" when finished\n');
%         input('USER INPUT: ', 's');
        % define full masks
        mybox = round(getPosition(myhr));
        delete(myhr);
        clear myhr;
        hold on;
        rectangle('Position', mybox);
        plot(mybox(1) + mybox(3)/2, mybox(2) + mybox(4)/2, 'ro');
        fprintf('centre %.1f %.1f\n', mybox(1) + mybox(3)/2, ...
            mybox(2) + mybox(4)/2);
        hold off;
        if rem(mybox(3), 2)
            mybox(3) = mybox(3) - 1;
        end
        if rem(mybox(4), 2)
            mybox(4) = mybox(4) - 1;
        end
        myi1 = mybox(2):(mybox(2) + mybox(4) - 1);
        myi2 = mybox(1):(mybox(1) + mybox(3) - 1);
        assert(rem(myi1(end) - myi1(1) + 1, 2) == 0);
        assert(rem(myi2(end) - myi2(1) + 1, 2) == 0);
%         mymask2 = zeros(size(mypf));
%         mymask2(myi1, myi2) = 1;
%         imwrite(mymask2, 'masks2.png');

        % crop interferogram
        myfringes = mypf(myi1, myi2);
        assert(rem(size(myfringes, 1), 2) == 0);

        figure(2);
        subplot(2, 2, 1);
        imagesc(mypf);
        axis equal;
        axis off;
        hold on;
        rectangle('Position', mybox);
        hold off;
        title('full');
        
        subplot(2, 2, 2);
        imagesc(myfringes);
        axis equal;
        axis off;
        title('circumscribed square');
        
        apm = fourier_apmask(myfringes);
        subplot(2, 2, 3);
        imagesc(apm);
        axis equal;
        axis off;
        title('aperture mask');
        
        myfringes(~apm) = 0;
        subplot(2, 2, 4);
        imagesc(myfringes);
        axis equal;
        axis off;
        title('interferogram');
        function [] = plot_centre_fringe_mask(reallymybox)
            title(...
                sprintf('[%4.1f, %4.1f, %4.1f, %4.1f] %4.1f, %4.1f', ...
                reallymybox(1), reallymybox(2), ...
                reallymybox(1) + reallymybox(3), ...
                reallymybox(2) + reallymybox(4), ...
                reallymybox(1) + reallymybox(3)/2, ...
                reallymybox(2) + reallymybox(4)/2));
            hold on;
            if ~isempty(cross_fringe_mask)
                delete(cross_fringe_mask);
            end
            reallymyradius = mean([reallymybox(3), reallymybox(4)]/2);
            reallymypos = ...
                [reallymybox(1), reallymybox(2)] + reallymyradius;
            cross_fringe_mask = plot(reallymypos(1), reallymypos(2), 'ro');
            hold off;
        end
    end

    function [myfftm, mybox] = define_fftmask(myp)
        figure(3);
        clf();
        imagesc(fourier_interf_fft(myp));
        axis equal;
        
        if ~isempty(last_masks) && ...
                size(last_masks.fftmask, 1) == size(myp, 1) && ...
                size(last_masks.fftmask, 2) == size(myp, 2) && ...
                numel(last_masks.fftmask) == numel(myp)
            mybox = last_masks.fftbox;
            myhr = imellipse(gca(), mybox);
        else
            myhr = imellipse(gca(), [10, 10, 200, 200]);
        end
        setFixedAspectRatioMode(myhr, 1);
        addNewPositionCallback(myhr, @plot_centre_fft_mask);
        fprintf('Double click in the circle to accept\n');
        wait(myhr);
        pause(.5);
%         fprintf('Select a mask around the first order\n');
%         fprintf('(a) Hit "Enter" when finished\n');
%         input('USER INPUT: ', 's');
        % define full masks
        mybox = getPosition(myhr);
        delete(myhr);
        clear myhr;
        hold on;
        rectangle('Position', mybox);
        hold off;
        myradius = mean([mybox(3), mybox(4)]/2);
        mypos = [mybox(1), mybox(2)] + myradius;
        hold on;
        plot(mypos(1), mypos(2), 'ro');
        plot(mypos(1) + myradius, mypos(2) + myradius, 'rx');
        plot(mypos(1) - myradius, mypos(2) + myradius, 'rx');
        plot(mypos(1) + myradius, mypos(2) - myradius, 'rx');
        plot(mypos(1) - myradius, mypos(2) - myradius, 'rx');
        hold off;
        myfftm = mask_fun(size(myp), mypos(1), mypos(2), myradius);
%         imwrite(myfftm, 'masks3.png');
        function [] = plot_centre_fft_mask(reallymybox)
            hold on;
            if ~isempty(cross_fft_mask)
                delete(cross_fft_mask);
            end
            reallymyradius = mean([reallymybox(3), reallymybox(4)]/2);
            reallymypos = ...
                [reallymybox(1), reallymybox(2)] + reallymyradius;
            cross_fft_mask = plot(reallymypos(1), reallymypos(2), 'ro');
            hold off;
        end
end
end
