function [c,ceq] = nonlincon(x,r_s, k_OV,k_SO, n_n, alpha, beta)
%NONLINCON nichtlineare Nebenbedingungen des optischen Schüttgutsortierers
%   Detailed explanation goes here

u_p = x(1:n_n);
u_n = x(n_n+1:2*n_n);
r_p = x(2*n_n+1:3*n_n+k_SO);
r_n = x(3*n_n+k_SO+1:4*n_n+2*k_SO);
r_TP = x(4*n_n+2*k_SO+1:5*n_n+2*k_SO);
r_FP = x(5*n_n+2*k_SO+1:6*n_n+2*k_SO);
r_FN = x(6*n_n+2*k_SO+1:7*n_n+2*k_SO);
r_TN = x(7*n_n+2*k_SO+1:8*n_n+2*k_SO);

ceq_tp = -r_TP(1:n_n-k_OV) +((1-alpha)*epsi(r_p(1:n_n-k_OV),r_n(1:n_n-k_OV)) + alpha*(1-ceta(r_p(1:n_n-k_OV),r_n(1:n_n-k_OV)))).*r_p(1:n_n-k_OV);
ceq_fp = -r_FP(1:n_n-k_OV) +(beta*epsi(r_p(1:n_n-k_OV),r_n(1:n_n-k_OV)) + (1-beta)*(1-ceta(r_p(1:n_n-k_OV),r_n(1:n_n-k_OV)))).*r_n(1:n_n-k_OV);
ceq_fn = -r_FN(1:n_n-k_OV) +(alpha*ceta(r_p(1:n_n-k_OV),r_n(1:n_n-k_OV)) + (1-alpha)*(1-epsi(r_p(1:n_n-k_OV),r_n(1:n_n-k_OV)))).*r_p(1:n_n-k_OV);
ceq_tn = -r_TN(1:n_n-k_OV) +((1-beta)*ceta(r_p(1:n_n-k_OV),r_n(1:n_n-k_OV)) + beta*(1-epsi(r_p(1:n_n-k_OV),r_n(1:n_n-k_OV)))).*r_n(1:n_n-k_OV);

ceq_P = r_p(k_OV+1:n_n) - u_p(k_OV+1:n_n).*r_TP(1:n_n-k_OV) - u_n(k_OV+1:n_n).*r_FN(1:n_n-k_OV) - r_s(1,k_OV+1:n_n)';
ceq_N = r_n(k_OV+1:n_n) - u_p(k_OV+1:n_n).*r_FP(1:n_n-k_OV) - u_n(k_OV+1:n_n).*r_TN(1:n_n-k_OV) - r_s(2,k_OV+1:n_n)';
ceq = [ceq_tp;ceq_fp;ceq_fn;ceq_tn;ceq_P; ceq_N];
c = [];
end

