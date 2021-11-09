function [y,epsilon,zeta] = calcY(qP,qN,o,z)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
epsilon = o(1)+o(2)*qP+o(3)*qN+o(4)*qP.^2+o(5)*qP.*qN+...
            o(6)*qN.^2;
zeta = z(1)+z(2)*qP+z(3)*qN+z(4)*qP.^2+z(5)*qP.*qN+...
        z(6)*qN.^2;
y = zeros(4,length(qP));
y(1,:) = epsilon.*qP;
y(2,:) = (1-zeta).*qN;
y(3,:) = (1-epsilon).*qP;
y(4,:) = zeta.*qN;
end

