function [y,epsilon,zeta] = calcY(qP,qN,scale)
% calcY: calculates the output of the separation unit
%   - qP accept particles int the separation unit
%   - qN reject particles in the separation unit
%   - scale: scaling factor if the TPR and TNR have to be reduced
%   - y: sorted particles:
%       1. accepted accept particles (TP)
%       2. accepted reject particles (FP)
%       3. rejected accept particles (FN)
%       4. rejected reject particles (TN)

% TPR
epsilon = epsilonSeparation(qP,qN,scale);
% TNR
zeta = zetaSeparation(qP,qN,scale);
y = zeros(4,length(qP));
y(1,:) = epsilon.*qP;
y(2,:) = (1-zeta).*qN;
y(3,:) = (1-epsilon).*qP;
y(4,:) = zeta.*qN;
end

