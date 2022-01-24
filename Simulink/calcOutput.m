function output = calcOutput(x,alpha,beta)
%CALC_OUTPUT Summary of this function goes here
%   Detailed explanation goes here
n = length(x)/4;
output = zeros(4,n);
output(1,:)  = (((1-alpha)*epsi(x(2*n+1:3*n),x(3*n+1:4*n)) + alpha*(1-ceta(x(2*n+1:3*n),x(3*n+1:4*n)))).*x(2*n+1:3*n))';
output(2,:) = ((beta*epsi(x(2*n+1:3*n),x(3*n+1:4*n)) + (1-beta)*(1-ceta(x(2*n+1:3*n),x(3*n+1:4*n)))).*x(3*n+1:4*n))';
output(3,:) =((alpha*ceta(x(2*n+1:3*n),x(3*n+1:4*n)) + (1-alpha)*(1-epsi(x(2*n+1:3*n),x(3*n+1:4*n)))).*x(2*n+1:3*n))';
output(4,:) = (((1-beta)*ceta(x(2*n+1:3*n),x(3*n+1:4*n)) + beta*(1-epsi(x(2*n+1:3*n),x(3*n+1:4*n)))).*x(3*n+1:4*n))';
end

