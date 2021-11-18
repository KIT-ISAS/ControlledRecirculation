function [J] = objectiveCalc_q(q,u,r,scale)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

[tp, fp, fn,tn] = calcY_symbolic(q(1),q(2),scale);
y = [tp; fp; fn; tn];
U = [1 0; 1 0; 0 1; 0 1]*u;
v = U.*y;
N = [1 0 1 0; 0 1 0 1];
eq = -q +N*v + r;
J = sumsqr(eq);
end

