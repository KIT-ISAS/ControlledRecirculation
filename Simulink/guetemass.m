function [J] = guetemass(x,n_n,c,alpha,beta, opt)
%GUETEMASS Zu minimierende Funktion
%   Input: Vektor, der die Zustände und die Stellgrößen entällt für die
%   kommenden n_n diskreten Zeitpunkte:
%       -Stellgroessen u_P
%       -u_N
%       -r_p
%       -r_n
switch opt
    case 1
        J = sum((x(2*n_n+1:3*n_n)- 5*ones(n_n,1)).*(x(2*n_n+1:3*n_n)- 5*ones(n_n,1)) + (x(3*n_n+1:4*n_n)- 2*ones(n_n,1)).*(x(3*n_n+1:4*n_n)- 2*ones(n_n,1)));
    case 2
        % Ausgaenge
        y = calcOutput(x,alpha,beta);
        y_TP = y(1,:);
        y_FP = y(2,:);
        y_FN = y(3,:);
        y_TN = y(4,:);
        tp = y_TP.*y_TP;
        fp = y_FP.*y_FP;
        fn = y_FN.*y_FN;
        tn = y_TN.*y_TN;
        J = c(1)*sum(tp(:)) + c(2)*sum(fp(:))+c(3)*sum(fn(:)) + c(4)*sum(tn(:));
    otherwise
        J = 0;
end
end

