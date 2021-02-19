function y = calcOutput_linearized(x,c)
%CALC_OUTPUT Summary of this function goes here
%   Detailed explanation goes here
n = length(x)/4;
y = zeros(4,n);
y(2,:) = (c(1,1)*x(2*n+1:3*n) + c(1,2)*x(3*n+1:4*n) + c(1,3))';
y(3,:) = (c(2,1)*x(2*n+1:3*n) + c(2,2)*x(3*n+1:4*n) + c(2,3))';
y(1,:) = (x(2*n+1:3*n)' - y(3,:));
y(4,:) = (x(3*n+1:4*n)' - y(2,:));
end

