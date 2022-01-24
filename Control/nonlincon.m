function [c,ceq] = nonlincon(x,r, k_hat,k_KL, k_LV,k_V,k_VK, n_n, scale)
%NONLINCON nichtlineare Nebenbedingungen des optischen Schüttgutsortierers


% states for the nonlinear equality constraints
% u(k+k_hat+1:k+n_n)
u_p = x(k_hat+1:n_n);
u_n = x(n_n+k_hat+1:2*n_n);
% q(k+k_VK+1:k-k_KL-k_LV+n_n)
q_p1 = x(2*n_n+k_VK+1:3*n_n-k_KL-k_LV);
q_n1 = x(3*n_n+k_VK+1:4*n_n-k_KL-k_LV);
% q(k+k_VK+k_hat+1:k+k_VK+n_n)
q_p2 = x(2*n_n+k_hat+1:3*n_n);
q_n2 = x(3*n_n+k_hat+1:4*n_n);

% y(k+k_KL+k_VK+1:k-k_LV+n_n)
y = calcY(q_p1,q_n1,scale);

%nonlinear equality constraints (ceq==0)
ceq_P = q_p2 - u_p.*y(1,:)' - u_n.*y(3,:)' - r(1,k_hat+k_V+1:n_n+k_V)';
ceq_N = q_n2 - u_p.*y(2,:)' - u_n.*y(4,:)' - r(2,k_hat+1:n_n)';
ceq = [ceq_P; ceq_N];
c = [];
end

