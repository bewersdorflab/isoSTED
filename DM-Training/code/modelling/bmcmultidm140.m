clear;
close all;
clc;

addpath('../mlib/');

% model Boston Multi-DM 140

%% this cell has a snippet extracted from Dan Burke's code
% d9684ee45fcb34fe3ec71a9219ab6269  membrane_mirror_modelling_BM
% 9e5edfe8a8a353d6452cffea93c17eb2  modelling/make_gaussian.m

nx=48;%36; %no of pixels used to model across mirror
%inter-actuator-spacing times the number of actuators across the pupil
ny=nx;
x=linspace(-nx/2,nx/2,nx); y=x;
[Y X]=meshgrid(x,y);
R=sqrt(X.^2+Y.^2);
mask=R<=22; %the aperture radius is 2.2mm
[row,col] = find(R>21.9 & R<22.1);

%mask=R<(round(225./2));
%actuators are equally spaced (2.5mm inter-actuator spacing)
isp=4;%44/12; %inter-actuator-spacing, 1pixel=0.1mm
%defining actuator positions (according to manual):
%there is one inter-act. spacing between the outermost actuators and the
%boundary of the membrane (--> important for the boundary condition of the
%differential equation)

for m=1:10;
    act_pos(m,:)=[isp+isp*m,isp];
end

for m=11:22;
    act_pos(m,:)=[isp*(m-10),2*isp];
end

for m=23:34;
    act_pos(m,:)=[isp*(m-22),3*isp];
end

for m=35:46;
    act_pos(m,:)=[isp*(m-34),4*isp];
end

for m=47:58;
    act_pos(m,:)=[isp*(m-46),5*isp];
end

for m=59:70;
    act_pos(m,:)=[isp*(m-58),6*isp];
end

for m=71:82;
    act_pos(m,:)=[isp*(m-70),7*isp];
end

for m=83:94;
    act_pos(m,:)=[isp*(m-82),8*isp];
end

for m=95:106;
    act_pos(m,:)=[isp*(m-94),9*isp];
end

for m=107:118;
    act_pos(m,:)=[isp*(m-106),10*isp];
end

for m=119:130;
    act_pos(m,:)=[isp*(m-118),11*isp];
end

for m=131:140;
    act_pos(m,:)=[isp+isp*(m-130),12*isp];
end

s_a=isp/2;   %half actuator side length
act=ones(s_a,s_a);

k=1;

%local deformation of the BMC is approximated as a gaussian
sigma_of_gaussian  = sqrt(-(isp^2) / (2*log(0.2)));

mm1 = [0; 0];
minmax = @(a) [min(a(:)), max(a(:))];
pic = cell(140, 1);
for m=1:140
    act=m; %active actuator
    
    P=zeros(nx,ny); 
    
    P(act_pos(act,1)-s_a:act_pos(act,1)+s_a,act_pos(act,2)-s_a:act_pos(act,2)+s_a)=k;

%     f=reshape(P,length(P)^2,1); %necessary for "poicalc"
%     u=poicalc(f,1,1,length(P),length(P));  %solve Poisson equation (=thin membrane equation)
%     M_full=reshape(u,length(P),length(P)).*mask; %membrane function
    
    u = make_gaussian( -(nx/2) + act_pos(act,2), -(nx/2) + act_pos(act,1), sigma_of_gaussian,sigma_of_gaussian,nx);
    
    M_full = u.*mask;
    
%     mask2=mask(round(end/2)-74:round(end/2)+74,round(end/2)-74:round(end/2)+74);
%     M=M_full(round(end/2)-74:round(end/2)+74,round(end/2)-74:round(end/2)+74).*mask2;
%     M=fliplr(-M).*mask2;
    M=fliplr(-M_full).*mask;
    %M=(M-min(M(:)))/max(M(:)-min(M(:))).*mask2; M=M/max(M(:));
    
%     M_ = M_full_(round(end/2)-74:round(end/2)+74,round(end/2)-74:round(end/2)+74).*mask2;
%     M_=fliplr(-M_).*mask2;

    pic{m} = M;
    mm1 = minmax([M(:); mm1(:)]);
end

spmm = 6;
spnn = 4;
spc = 1;
spbase = 10;
sfigure(spbase);
for m=1:140;
    subplot(spmm, spnn, spc);
    imagesc(pic{m}, mm1)
    axis off;
    title(sprintf('act # %d', m));
    spc = spc + 1;
    if spc == spmm*spnn + 1
        spbase = spbase + 1;
        sfigure(spbase);
        spc = 1;
    end
end
%% save output

dsspec = struct();
dsspec.apmask = mask;
dsspec.nsupp = sum(dsspec.apmask(:));

Yout = zeros(dsspec.nsupp, 140);
for i=1:140
    Phi = pic{i};
    Yout(:, i) = Phi(dsspec.apmask);
end
Uin = eye(140);

% save modelling data
name = 'bmcmultidm140';
save(sprintf('%s/%s.mat', name, name), 'dsspec', 'Uin', 'Yout');

% save plot stuff (not used for DM training)
save(sprintf('%s/plotdata_dmactpos.mat', name), 'act_pos', 'isp');
copyfile(sprintf('%s/plotdata_dmactpos.mat', name), ...
    '../plotdata_dmactpos.mat', 'f');
