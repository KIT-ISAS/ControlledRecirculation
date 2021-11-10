function r = getSzenario(folder)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% szenario file
file = strcat(folder,'\szenario.mat');
S = load(file);
rP = S.szenario.rP;
rN = S.szenario.rN;
r = [rP; rN];
end

