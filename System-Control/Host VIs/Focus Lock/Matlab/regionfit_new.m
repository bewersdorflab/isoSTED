function [cmx cmy sx sy]=regionfit(region)

% imsz=size(region,1);
% xlin=1:1:imsz;
% ylin=imsz:-1:1;
% [xx yy]=meshgrid(xlin,ylin);
% cmx=sum(sum(xx.*region))./sum(region(:));
% cmy=sum(sum(yy.*region))./sum(region(:));
% sx=sum(sum(abs(xx-cmx).*region))./sum(region(:));
% sy=sum(sum(abs(yy-cmy).*region))./sum(region(:));

imsz=size(region,1);
[X Y]= meshgrid(1:imsz,1:imsz);
[y,x] = find(region==max(region(:)));
initpar = double([mean(x),mean(y),5,5,min(region(:)),max(region(:))]);
xdata = [X,Y];
options = optimset('Display','off','MaxFunEvals',1e7,'MaxIter',100,'TolFun',0.01);
f = @(xp,xdata)xp(6)*(exp(-0.5*(X-xp(1)).^2./(xp(3)^2)-0.5*(Y-xp(2)).^2./(xp(4)^2)))+xp(5);
[lp,~,~,exitflag]=lsqcurvefit(f,initpar,xdata,region,[],[],options);
cmx = lp(1);
cmy = imsz-lp(2);
sx = lp(3);
sy = lp(4);