function J_new = objectiveOO(u,y,r,scale,cTP,cFP,cFN,cTN,opt)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
% Für eine Maximierung der TPR/TNR müssen die Parameter cP, cN negativ sein
qP_new = r(1)+u(1)*y(1) + u(2)*y(3);
qN_new = r(2)+u(1)*y(2) + u(2)*y(4);
e_new = epsilonSeparation(qP_new,qN_new,scale);
z_new = zetaSeparation(qP_new,qN_new,scale);
switch opt
    case 1
        TP = (1-u(1)).*e_new.*qP_new;
        FP = (1-u(1)).*(1-z_new).*qN_new;
        FN = (1-u(2)).*(1-e_new).*qP_new;
        TN = (1-u(2)).*z_new.*qN_new;
        J_new = cTP*TP+cFP*FP+cFN*FN+cTN*TN;
    case 2
        TPR_re = e_new*(1 - u(1))/((u(2) - u(1))*e_new - u(2) + 1);
        TNR_re = z_new*(-1 + u(2))/((u(2) - u(1))*z_new - 1 + u(1));
        J_new = cTP*TPR_re + cTN*TNR_re;
end
end

