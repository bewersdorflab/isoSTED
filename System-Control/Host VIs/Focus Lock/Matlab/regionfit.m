function [cmx cmy sx sy]=regionfit(region)

imsz=size(region,1);
xlin=1:1:imsz;
ylin=imsz:-1:1;
[xx yy]=meshgrid(xlin,ylin);
cmx=sum(sum(xx.*region))./sum(region(:));
cmy=sum(sum(yy.*region))./sum(region(:));
sx=sum(sum(abs(xx-cmx).*region))./sum(region(:));
sy=sum(sum(abs(yy-cmy).*region))./sum(region(:));