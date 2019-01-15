function phase_unwrap

global setup;

temp=single(setup.phase);
setup.phase = Miguel_2D_unwrapper(temp);

%figure(7);
%surf(setup.unwrapped);
%shading interp;

% show unwrapped phase
%figure(8);
%imshow(setup.unwrapped,[]);
%colormap(jet); colorbar

%figure(9);
%imshow(setup.phase,[]);
%colormap(jet); colorbar
        
end