function [J] = guetemass(parameters,x_values,y_values,z_values,n_parameters, N)
%GUETEMASS Summary of this function goes here
%   Detailed explanation goes here
% n = length(z_values);
% z_approx = poly3D(parameters,x_values,y_values,dim_x,dim_y,n);
% J = sumsqr(z_values-z_approx);
J = sumsqr(z_values'-parameters(n_parameters+1:n_parameters+N));
end

