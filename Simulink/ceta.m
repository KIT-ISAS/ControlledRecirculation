function [tn] = ceta(xp,xn)
%CETA Summary of this function goes here
%   Detailed explanation goes here

p1 =   -0.003787;
p2 =     0.05479;
p3 =      0.5837;
p4 = 0.007;
tn = p1*(xp+xn).^2 + p2*(xp+xn) + p3 +p4*xn;
end

