function [x_opt] = mpc(r_s, x0, r_linie_old, n_n, k_OV, k_SO, lb, ub, n_x, c_1, c_2, alpha, beta, options)
%MPC Modellprädiktiver Regler für die Regelung einer Partikelrückführung
%für einen optischen Schüttgutsortierer.
%   Input:
%      -r_s: Matrix mit den Dimensionen 2,P; 
%       Dabei handelt es sich um die Vorhersage wie viele Gutpartikel 
%       (1. Zeile) und wie viele Schlechtpartikel (2. Zeile) von 
%       vorhergegangenen Prozessen auf das Fließband fallen
%      -r_linie: Matrix mit den Dimensionen 4,1:
%       Anzahl Partikel die pro s zum Zeitpunkt T*k auf der Rutsche fließen
%       aufgeteilt nach:
%           -1. Zeile: Gutpartikel auf der Gutpartikelrutsche (TP)
%           -2. Zeile: Schlechtpartikel auf der Gutpartikelrutsche (FP)
%           -3. Zeile: FN
%           -4. Zeile: TN
%      -r_kamera: Matrix mit den Dimensionen 2,1:
%       Partikel die sich zum Zeitpunkt k*T auf dem Fließband befinden
%       aufgeteilt in Gutpartikel (1. Zeile) und Schlechtpartikel (2.Zeile)
%      -x_old: Optimale Steuergrößenfolge aus der letzten Optimierung, die
%       als Startwert für die kommende Optimierung genutzt wird.
%      -T: Abtastzeit
%      -n_n: Steuerhorizont

%% Achtung
% -Teilweise gelten Bedingungen für n_n (müssen noch hinzugefügt werden)
% -Die Zustände und Stellgrößen starten zu unterschiedlichen Zeitpunkten
%  aufgrund der vielen Totzeiten

%% Parameter
% Prädiktionshorizont:
n_p = length(r_s);

% linear equality constraints
if n_n < k_SO
    print('n_n darf nicht kleiner als k_SO sein')
elseif n_n <= k_OV
    beq = [r_s(1,1:n_n-1)';r_s(2,1:n_n-1)'];
    Aeq = zeros(2*n_n, n_x*n_n+2*k_SO);
    Aeq_P = [-1*eye(n_n).*r_linie_old(1,1:n_n), -1*eye(n_n).*r_linie_old(3,1:n_n),zeros(n_n,k_SO),eye(n_n)];
    Aeq_N = [-1*eye(n_n).*r_linie_old(2,1:n_n), -1*eye(n_n).*r_linie_old(4,1:n_n),zeros(n_n,k_SO),zeros(n_n,n_n), zeros(n_n,k_SO), eye(n_n)];
    Aeq(1:n_n,1:(3*n_n)+k_SO) = Aeq_P;
    Aeq(n_n+1:2*n_n,1:(4*n_n)+2*k_SO) = Aeq_N;   
else 
    beq = [r_s(1,1:k_OV)';r_s(2,1:k_OV)'];
    Aeq = zeros(2*k_OV, n_x*n_n+2*k_SO);
    Aeq_P = [-1*eye(k_OV).*r_linie_old(1,:), zeros(k_OV,n_n-k_OV), -1*eye(k_OV).*r_linie_old(3,:), zeros(k_OV,n_n-k_OV), ...
        zeros(k_OV,k_SO), eye(k_OV)];
    Aeq_N = [-1*eye(k_OV).*r_linie_old(2,:),zeros(k_OV,n_n-k_OV), -1*eye(k_OV).*r_linie_old(4,:), zeros(k_OV,n_n-k_OV), ...
        zeros(k_OV,n_n+2*k_SO), eye(k_OV)];
    Aeq(1:k_OV,1:(2*n_n)+k_SO+k_OV) = Aeq_P;
    Aeq(k_OV+1:2*k_OV,1:(3*n_n)+2*k_SO+k_OV) = Aeq_N;
end
% sparse Matrix ist zeitsparend
Aeq_sparse = sparse(Aeq);
beq_sparse = sparse(beq);
% Nichtlineare Nebenbedingungen
if n_n <= k_OV
    x_opt = fmincon(@(x)guetemass(x,n_n,c_1,c_2),x0,[],[],Aeq_sparse,beq_sparse,lb,ub,options);
else
    x_opt = fmincon(@(x)guetemass(x,n_n,c_1,c_2),x0,[],[],Aeq_sparse,beq_sparse,lb,ub,@(x)nonlincon(x,r_s, k_OV, k_SO, n_n,alpha,beta),options);
end

