function [c,ceq] = nonlincon(x,r_s, k_OV, n_n, alpha, beta)
%NONLINCON nichtlineare Nebenbedingungen des optischen Schüttgutsortierers
%   Detailed explanation goes here
scale = 1;
u_p = x(1:n_n);
u_n = x(n_n+1:2*n_n);
q_P = x(2*n_n+1:3*n_n);
q_N = x(3*n_n+1:4*n_n);

y = calcY(q_P,q_N, scale);

ceq_P = q_P(k_OV+1:n_n) - u_p(k_OV+1:n_n).*y(1,:)' - u_n(k_OV+1:n_n).*y(3,:)' - r_s(1,k_OV+1:n_n)';
ceq_N = q_N(k_OV+1:n_n) - u_p(k_OV+1:n_n).*y(2,:)' - u_n(k_OV+1:n_n).*y(4,:)' - r_s(2,k_OV+1:n_n)';
ceq = [ceq_P; ceq_N];
c = [];
end

