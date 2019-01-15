function remove_tilt

global setup;

% linearize data for plane fitting
[X,Y]=meshgrid(1:setup.img_size(2),1:setup.img_size(1));
X=X(:);
Y=Y(:);
data=setup.phase(:);

% fit the data with plane fitting and extract coefficients
coeff=fit([X Y],data,'poly11');   % linear surface fit to determine mirror tilt
setup.a0=coeff.p00;
setup.a1=coeff.p01;
setup.a2=coeff.p10;

phase_tilt=zeros(setup.img_size);
for ii=1:setup.img_size(1)
    for jj=1:setup.img_size(2)
        % correct phase by subtracting fitted plane
        phase_tilt(ii,jj)=setup.phase(ii,jj)-setup.a0-setup.a1*ii-setup.a2*jj;
    end
end

setup.phase=phase_tilt;

end