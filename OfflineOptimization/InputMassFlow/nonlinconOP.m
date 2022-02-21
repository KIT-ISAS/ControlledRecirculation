function [c,ceq] = nonlinconOP(x,r,scale)
%UNTITLED Equality constraints of the offline optimization. 
u = x(1:2);
q = x(3:4);
y = calcY(q(1),q(2),scale);
U = [1 0; 1 0; 0 1; 0 1]*u;
v = U.*y;
N = [1 0 1 0; 0 1 0 1];
c = [];
ceq = -q +N*v + r;
end

