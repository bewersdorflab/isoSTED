function out=ChangeVariableName(in)
% CHANGEVARIABLENAME is a program that can be used to change the name of
% the imported variable from the .mat file.
%
% .mat file can only include one variable matrix.
%
% in: the string correponding to the full path of .mat file
% out: the matrix inside .mat file
%
% coded by HAO, Xiang
% first coded on Jul. 24, 2014
% last updated on Jul. 24, 2014

temp=load(in);  % load data
na=fieldnames(temp);
out=getfield(temp,char(na));