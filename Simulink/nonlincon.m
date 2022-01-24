function [c,ceq] = nonlincon(x,r_s, k_OV, n_n, alpha, beta)
%NONLINCON nichtlineare Nebenbedingungen des optischen Schüttgutsortierers
%   Detailed explanation goes here

u_p = x(1:n_n);
u_n = x(n_n+1:2*n_n);
q_p = x(2*n_n+1:3*n_n);
q_n = x(3*n_n+1:4*n_n);

x_2 = [u_p(k_OV+1:n_n); u_n(k_OV+1:n_n); q_p(k_OV+1:n_n); q_n(k_OV+1:n_n)];

y = calcOutput(x_2, alpha,beta);

ceq_P = q_p(k_OV+1:n_n) - u_p(k_OV+1:n_n).*y(1,:)' - u_n(k_OV+1:n_n).*y(3,:)' - r_s(1,k_OV+1:n_n)';
ceq_N = q_n(k_OV+1:n_n) - u_p(k_OV+1:n_n).*y(2,:)' - u_n(k_OV+1:n_n).*y(4,:)' - r_s(2,k_OV+1:n_n)';
ceq = [ceq_P; ceq_N];
c = [];
end

