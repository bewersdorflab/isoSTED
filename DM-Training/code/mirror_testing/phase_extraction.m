function phase_extraction

global setup;

img=setup.img;
%% Part 1: Fast Fourier Transformation
freq=fft2(img);
freq_shift=fftshift(freq);  % shift zero-frequency to center
freq_abs=abs(freq_shift);   % take the norm of complex number
freq_abs_log=log(freq_abs);    % use log to smoothen the image for display

% with smoothing...
%{
K = wiener2(img,[5 5]);
freq_K=fft2(K);
freq_K_shift=fftshift(freq_K); 
freq_K_abs=abs(freq_K_shift);   
freq_K_abs_log=log(freq_K_abs);
%}

%figure(1);
%imshow(img,[]);

% show fourier transformed image
% figure(10);
% imshow(freq_abs_log,[]);
% colormap(jet); colorbar


%% Part2: Shift frequency domain peak
% This process is aimed to shift the frequency domain in order to
% eliminate interference friges

freq_new=zeros(setup.img_size);
for i=-setup.signal_size(1):setup.signal_size(1)
    for j=-setup.signal_size(2):setup.signal_size(2)
        % shift the frequency domain signal peak into center (also crop
        % small area leaving other areas zero)
        % *** the best way for understanding the operation is to compare showed
        % images
        freq_new(i+setup.img_center(1),j+setup.img_center(2))=freq_shift(setup.signal_cor(2)+i,setup.signal_cor(1)+j);
    end
end
freq_new_abs=abs(freq_new);
freq_new_abs_log=log(freq_new_abs);

%{
figure(3);
imshow(freq_new_abs_log,[]);
colormap(jet); colorbar
%}

freq_new_shift=ifftshift(freq_new);

% image ifft2 after translation of center in frequency domain
img_new=ifft2(freq_new_shift);
img_new_log=log(img_new);   % take log for display
phase=imag(img_new_log);

setup.phase=phase;


%figure(4);
%imshow(phase,[]);
%colormap(jet); colorbar
%}

end

