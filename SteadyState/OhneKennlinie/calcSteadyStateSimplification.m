clear
syms e z u_p u_n real positive
syms tpr_s(u_p,u_n) tnr_s(u_p,u_n) J(u_p,u_n)
tpr = e*(1-u_p)./(1-(u_p-u_n)*e-u_n);
tnr = z*(1-u_n)./(1-(u_n-u_p)*z-u_p);
% epsilon and zeta values
e = 0.97;
z = 0.98;
tpr(u_p,u_n) = subs(tpr);
tnr(u_p,u_n) = subs(tnr);
J(u_p,u_n) =(tpr(u_p,u_n) + tnr(u_p,u_n))/2;
eqP = diff(J(u_p,u_n),u_p) == 0;
eqN = diff(J(u_p,u_n),u_n) == 0;
constraints = [u_p<=1, u_n <=1];
% solve system algebraically
[uN_opt,uP_opt,parameters,conditions] = solve([eqP,eqN,constraints],[u_n,u_p],'ReturnConditions', true);
% needed for the plotting
uP_min = solve(uN_opt==0,uP_opt);
uN_min = double(subs(uN_opt,0));