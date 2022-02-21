function [y_mean] = calcParticleMean(y,i_min,i_max)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
y_sum = sum(y(:,i_min:i_max),2);
y_mean = y_sum/(i_max-i_min);
end

