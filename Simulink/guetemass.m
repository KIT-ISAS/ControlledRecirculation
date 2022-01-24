function [J] = guetemass(x,n_n,c,alpha,beta, opt,D, q_op)
%GUETEMASS Zu minimierende Funktion
%   Input: Vektor, der die Zustände und die Stellgrößen entällt für die
%   kommenden n_n diskreten Zeitpunkte:
%       -Stellgroessen:
%       -u_P
%       -u_N
%       -q_p
%       -q_n
q_p = x(2*n_n+1:3*n_n);
q_n = x(3*n_n+1:4*n_n);
switch opt
    case 1
        J = sum(c(1)*(x(2*n_n+1:3*n_n)- q_op(1)*ones(n_n,1)).^2 + c(2)*(x(3*n_n+1:4*n_n)- q_op(2)*ones(n_n,1)).^2);
    case 2
        % Wkeit, dass ein Gutpartikel falsch sortiert wird
        y_P =alpha*ceta(q_p,q_n) + (1-alpha)*(1-epsi(q_p,q_n));
        % Wkeit, dass ein Schlechtpartikel falsch sortiert wird
        y_N = (1-beta)*ceta(q_p,q_n) + beta*(1-epsi(q_p,q_n));
        J = c(1)*sum(y_P) + c(2)*sum(y_N);
    case 3
        y = calcOutput_linearized(x,D);
        y_TP = y(1,:);
        y_FP = y(2,:);
        y_FN = y(3,:);
        y_TN = y(4,:);
        tp = y_TP.*y_TP;
        fp = y_FP.*y_FP;
        fn = y_FN.*y_FN;
        tn = y_TN.*y_TN;
        J = sum(tp(:)) + c(1)*sum(fp(:))+c(2)*sum(fn(:)) +sum(tn(:));
%     case 4
%         y_TP  = (((1-alpha)*epsi(q_p,q_n) + alpha*(1-ceta(q_p,q_n))).*q_p)';
%         y_FP = ((beta*epsi(q_p,q_n) + (1-beta)*(1-ceta(q_p,q_n))).*q_n)';
%         y_FN =((alpha*ceta(q_p,q_n) + (1-alpha)*(1-epsi(q_p,q_n))).*q_p)';
%         y_TN = (((1-beta)*ceta(q_p,q_n) + beta*(1-epsi(q_p,q_n))).*q_n)';
%         tp = y_TP.*y_TP;
%         fp = y_FP.*y_FP;
%         fn = y_FN.*y_FN;
%         tn = y_TN.*y_TN;
%         J = c(1)*sum(tp(:)) + c(2)*sum(fp(:))+c(3)*sum(fn(:)) + c(4)*sum(tn(:));
    otherwise
        J = 0;
     
end
end

