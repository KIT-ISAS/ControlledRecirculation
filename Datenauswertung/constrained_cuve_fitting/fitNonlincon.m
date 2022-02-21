function [c,ceq] = fitNonlincon(parameters,dim_x,dim_y)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
x_values = 0:1:10000;
y_values = 0:1:10000;
rateMax = poly3D(parameters,x_values,y_values,dim_x,dim_y,n)-ones(1,n);
rateMin = -1*poly3D(parameters,x_values,y_values,dim_x,dim_y,n);
ceq = [];
c = [rateMax;rateMin];
end

