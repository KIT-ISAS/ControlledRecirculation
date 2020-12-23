function [J] = guetemass(x,n_n,c_1,c_2)
%GUETEMASS Zu minimierende Funktion
%   Input: Vektor, der die Zustände und die Stellgrößen entällt für die
%   kommenden n_n diskreten Zeitpunkte:
%       -Stellgroessen u_P
%       -u_N
%       -r_p
%       -r_n
%       -r_TP
%       -r_FP
%       -r_FN
%       -r_TN

% Zustände
r_TP = x(3*n_n+1:4*n_n);
r_FP = x(4*n_n+1:5*n_n);
r_FN = x(5*n_n+1:6*n_n);
r_TN = x(6*n_n+1:7*n_n);
% PPV und NPV
PPV = r_TP./(r_TP + r_FP);
NPV = r_TN./(r_TN + r_FN);
% Eigentliches Gütemaß
J = -c_1*sum(PPV)-c_2*sum(NPV);
end

