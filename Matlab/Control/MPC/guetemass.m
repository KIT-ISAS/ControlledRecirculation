function [J] = guetemass(x,n_n,c_1,c_2,alpha,beta)
%GUETEMASS Zu minimierende Funktion
%   Input: Vektor, der die Zustände und die Stellgrößen entällt für die
%   kommenden n_n diskreten Zeitpunkte:
%       -Stellgroessen u_P
%       -u_N
%       -r_p
%       -r_n

% Ausgaenge
y = calcOutput(x,alpha,beta,n_n);
y_TP = y(1,:);
y_FP = y(2,:);
y_FN = y(3,:);
y_TN = y(4,:);
% PPV und NPV
PPV = y_TP./(y_TP + y_FP);
NPV = y_TN./(y_TN + y_FN);
% Eigentliches Gütemaß
J = -c_1*sum(PPV)-c_2*sum(NPV);
end

