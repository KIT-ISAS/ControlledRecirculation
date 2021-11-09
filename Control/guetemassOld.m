function [J] = guetemassOld(x,n_n,k_full,c, y_known,o,z, opt, q_op)
%GUETEMASS Zu minimierende Funktion
%   Input: Vektor, der die Zustände und die Stellgrößen entällt für die
%   kommenden n_n diskreten Zeitpunkte:
%       -Stellgroessen:
%       -u_P
%       -u_N
%       -q_p
%       -q_n
% k_full = k_KO + k_OL + k_V + k_SK
q_p = x(2*n_n+1:3*n_n);
q_n = x(3*n_n+1:4*n_n);
uP = x(1:n_n);
uN = x(n_n+1:2*n_n);
delta= 0.000001;
switch opt
    case 1
        J = sum(c(1)*(x(2*n_n+1:3*n_n)- q_op(1)*ones(n_n,1)).^2 + c(2)*(x(3*n_n+1:4*n_n)- q_op(2)*ones(n_n,1)).^2);
    case 2
        if n_n>k_full
            uP_1 = uP(1:k_full);
            uN_1 = uN(1:k_full);
            uP_2 = uP(k_full+1:n_n);
            uN_2 = uN(k_full+1:n_n);
            TP1 = (1-uP_1).*y_known(1,:);
            FP1 = (1-uP_1).*y_known(2,:);
            FN1 = (1-uN_1).*y_known(3,:);
            TN1 = (1-uN_1).*y_known(4,:);
            y_var = calcY(q_p,q_n,o,z);
            TP2 = (1-uP_2).*y_var(1,:);
            FP2 = (1-uP_2).*y_var(2,:);
            FN2 = (1-uN_2).*y_var(3,:);
            TN2 = (1-uN_2).*y_var(4,:);
            TP = [TP1 TP2];
            FP = [FP1 FP2];
            FN = [FN1 FN2];
            TN = [TN1 TN2];
        else
%             % Wkeit, dass ein Gutpartikel falsch sortiert wird
%             y_P =alpha*ceta(q_p,q_n) + (1-alpha)*(1-epsi(q_p,q_n));
%             % Wkeit, dass ein Schlechtpartikel falsch sortiert wird
%             y_N = (1-beta)*ceta(q_p,q_n) + beta*(1-epsi(q_p,q_n));
%             J = c(1)*sum(y_P) + c(2)*sum(y_N);
            TP = (1-uP)'.*y_known(1,:);
            FP = (1-uP)'.*y_known(2,:);
            FN = (1-uN)'.*y_known(3,:);
            TN = (1-uN)'.*y_known(4,:);
        end
        J = c(1)*sum(TP) + c(2)*sum(FP) + c(3)*sum(FN) + c(4)*sum(TN);
    case 3
        if n_n>k_full
            uP_1 = uP(1:k_full);
            uN_1 = uN(1:k_full);
            uP_2 = uP(k_full+1:n_n);
            uN_2 = uN(k_full+1:n_n);
            TP1 = (1-uP_1).*y_known(1,:);
            FP1 = (1-uP_1).*y_known(2,:);
            FN1 = (1-uN_1).*y_known(3,:);
            TN1 = (1-uN_1).*y_known(4,:);
            y_var = calcY(q_p,q_n,o,z);
            TP2 = (1-uP_2).*y_var(1,:);
            FP2 = (1-uP_2).*y_var(2,:);
            FN2 = (1-uN_2).*y_var(3,:);
            TN2 = (1-uN_2).*y_var(4,:);
            TP = [TP1 TP2];
            FP = [FP1 FP2];
            FN = [FN1 FN2];
            TN = [TN1 TN2];
        else
%             % Wkeit, dass ein Gutpartikel falsch sortiert wird
%             y_P =alpha*ceta(q_p,q_n) + (1-alpha)*(1-epsi(q_p,q_n));
%             % Wkeit, dass ein Schlechtpartikel falsch sortiert wird
%             y_N = (1-beta)*ceta(q_p,q_n) + beta*(1-epsi(q_p,q_n));
%             J = c(1)*sum(y_P) + c(2)*sum(y_N);
            TP = (1-uP)'.*y_known(1,:);
            FP = (1-uP)'.*y_known(2,:);
            FN = (1-uN)'.*y_known(3,:);
            TN = (1-uN)'.*y_known(4,:);
        end
        % maximization of the sorting system TPR/TNR
        [~,epsilon,zeta] = calcY(q_p,q_n,o,z);
        J_ez = c(1)*sum(epsilon) + c(4)*sum(zeta);
        % maximization of the overall system TPR/TNR
        TPR = TP./(TP+FN+delta);
        TNR = TN./(TN+FP+delta);
        J_R =c(1)*sum(TPR) +c(4)*sum(TNR);
        J =J_ez + J_R;
    otherwise
        J = 0;
     
end
end

