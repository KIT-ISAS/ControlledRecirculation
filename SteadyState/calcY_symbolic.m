function [tp,fp,fn,tn] = calcY_symbolic(qP,qN,scale)
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
% epsilon = 0.9;
epsilon = epsilonSeparationSym(qP,qN,scale);
% TNR
% zeta = 0.8;
zeta = zetaSeparationSym(qP,qN,scale);
tp = epsilon.*qP;
fp = (1-zeta).*qN;
fn = (1-epsilon).*qP;
tn = zeta.*qN;
end

