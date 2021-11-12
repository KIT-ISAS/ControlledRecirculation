function r = getSzenario(folder,fileName)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% szenario file
file = strcat(folder,fileName);
S = load(file);
rP = S.szenario.rP;
rN = S.szenario.rN;
r = [rP; rN];
end

