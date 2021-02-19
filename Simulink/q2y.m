function y = q2y(q,alpha,beta)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
p = q(1); 
n = q(2);
% epsilon
p1 =   -0.003787;
p2 =     0.05479;
p3 =      0.6837;
p4 = -0.007;
epsilon = epsi(p,n);
% zeta
zeta = ceta(p,n);
% Partikel auf der Rutsche
fp = (beta*epsilon+(1-beta)*(1-zeta)).*n;
fn = (alpha*zeta+(1-alpha)*(1-epsilon)).*p;
tp = p - fn;
tn = n - fp;
y = [tp; fp; fn; tn];
end

