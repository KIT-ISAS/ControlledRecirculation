function J_new = objectiveOP(x,scale,c,opt)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% Für eine Maximierung der TPR/TNR müssen die Parameter cP, cN negativ sein
cTP = c(1);
cFP = c(2);
cFN = c(3);
cTN = c(4);
qP = x(3);
qN = x(4);
e_new = epsilonSeparation(qP,qN,scale);
z_new = zetaSeparation(qP,qN,scale);
switch opt
    case 1
        TP = (1-x(1)).*e_new.*qP;
        FP = (1-x(1)).*(1-z_new).*qN;
        FN = (1-x(2)).*(1-e_new).*qP;
        TN = (1-x(2)).*z_new.*qN;
        J_new = cTP*TP+cFP*FP+cFN*FN+cTN*TN;
    case 2
        TPR_re = e_new*(1 - x(1))/((x(2) - x(1))*e_new - x(2) + 1);
        TNR_re = z_new*(-1 + x(2))/((x(2) - x(1))*z_new - 1 + x(1));
        J_new = cTP*TPR_re + cTN*TNR_re;
end
end

