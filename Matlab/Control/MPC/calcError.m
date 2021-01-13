function error = calcError(x, n_n, k_SO, alpha, beta)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
i = 6;
error = zeros(1,4);
error(1) = - x(4*n_n+2*k_SO+i) + ((1-alpha)*epsi(x(2*n_n+i),x(3*n_n+k_SO+i)) + alpha*(1-ceta(x(2*n_n+i),x(3*n_n+k_SO+i)))).*x(2*n_n+i);
error(2) = - x(5*n_n+2*k_SO+i) +(beta*epsi(x(2*n_n+i),x(3*n_n+k_SO+i)) + (1-beta)*(1-ceta(x(2*n_n+i),x(3*n_n+k_SO+i)))).*x(3*n_n+k_SO+i);
error(3) = - x(6*n_n+2*k_SO+i) +(alpha*ceta(x(2*n_n+i),x(3*n_n+k_SO+i)) + (1-alpha)*(1-epsi(x(2*n_n+i),x(3*n_n+k_SO+i)))).*x(2*n_n+i);
error(4) = - x(7*n_n+2*k_SO+i) +((1-beta)*ceta(x(2*n_n+i),x(3*n_n+k_SO+i)) + beta*(1-epsi(x(2*n_n+i),x(3*n_n+k_SO+i)))).*x(3*n_n+k_SO+i);
end

