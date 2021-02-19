function [tp] = epsi(xp,xn)
%EPSI Summary of this function goes here
%   Detailed explanation goes here

p1 =   -0.003787;
p2 =     0.05479;
p3 =      0.6837;
p4 = -0.007;
tp = p1*(xp+xn).^2 + p2*(xp+xn) + p3 +p4*xn;
end