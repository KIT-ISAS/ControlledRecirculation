function z_approx = poly3D(parameters,x_values,y_values,dim_x,dim_y,n)
%POLY3D Summary of this function goes here
%   Detailed explanation goes here
z_approx = zeros(1,n);
k = 1;
for i=0:dim_y
    for j =0:(dim_x-i)
        z_approx = z_approx + parameters(k)*x_values.^j.*y_values.^i;
        k = k + 1;
    end
end
end

