function output = calcOutput(x,alpha,beta,n_n)
%CALC_OUTPUT Summary of this function goes here
%   Detailed explanation goes here
output = zeros(4,n_n);
output(1,:)  = (((1-alpha)*epsi(x(2*n_n+1:3*n_n),x(3*n_n+1:4*n_n)) + alpha*(1-ceta(x(2*n_n+1:3*n_n),x(3*n_n+1:4*n_n)))).*x(2*n_n+1:3*n_n))';
output(2,:) = ((beta*epsi(x(2*n_n+1:3*n_n),x(3*n_n+1:4*n_n)) + (1-beta)*(1-ceta(x(2*n_n+1:3*n_n),x(3*n_n+1:4*n_n)))).*x(3*n_n+1:4*n_n))';
output(3,:) =((alpha*ceta(x(2*n_n+1:3*n_n),x(3*n_n+1:4*n_n)) + (1-alpha)*(1-epsi(x(2*n_n+1:3*n_n),x(3*n_n+1:4*n_n)))).*x(2*n_n+1:3*n_n))';
output(4,:) = (((1-beta)*ceta(x(2*n_n+1:3*n_n),x(3*n_n+1:4*n_n)) + beta*(1-epsi(x(2*n_n+1:3*n_n),x(3*n_n+1:4*n_n)))).*x(3*n_n+1:4*n_n))';
end

