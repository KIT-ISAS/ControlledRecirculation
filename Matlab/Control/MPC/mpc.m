function [x_opt] = mpc(r_s, x0, y, n_n, k_OV, k_SO, lb, ub, n_x, c_1, c_2, alpha, beta, options)
%MPC Modellprädiktiver Regler für die Regelung einer Partikelrückführung
%für einen optischen Schüttgutsortierer.
%   Input:
%      -r_s: Matrix mit den Dimensionen 2,P; 
%       Dabei handelt es sich um die Vorhersage wie viele Gutpartikel 
%       (1. Zeile) und wie viele Schlechtpartikel (2. Zeile) von 
%       vorhergegangenen Prozessen auf das Fließband fallen
%       Zeitschritte: k+1 ... k+n_m
%      -x0: Optimale Steuergrößenfolge aus der letzten Optimierung, die
%       als Startwert für die kommende Optimierung genutzt wird.
%      -y: Matrix mit den Dimensionen 4,1:
%       Anzahl Partikel die pro s zu den letzten k_OV Zeitpunkten auf der 
%       Rutsche fließen aufgeteilt nach:
%           -1. Zeile: Gutpartikel auf der Gutpartikelrutsche (TP)
%           -2. Zeile: Schlechtpartikel auf der Gutpartikelrutsche (FP)
%           -3. Zeile: FN
%           -4. Zeile: TN
%       Die Zeitschritte reichen dabei von k+1-k_OV ... k+n_n-k_OV
%      -r_kamera: Matrix mit den Dimensionen 2,1:
%       Partikel die sich zum Zeitpunkt k*T auf dem Fließband befinden
%       aufgeteilt in Gutpartikel (1. Zeile) und Schlechtpartikel (2.Zeile)
%       (ist noch nicht aufgenommen, lässt sich aber eventuell hinzufügen)
%      -n_n: Steuerhorizont
%      -k_OV: Anzahl Zeitschritte, die ein Partikel benötigt, um die
%       Distanz zwischen Ausschleuseeinheit und Fließband zurückzulegen
%      -k_SO: Anzahl Zeitschritte, die ein Partikel benötigt, um die
%       Distanz zwischen Ausschleuseeinheit und Fließband zurückzulegen
%      -lb: lower bounds des Optimierungsvektors
%      -ub: upper bounds des Optimierungsvektors
%      -n_x: Anzahl Zustände + Regelgrößen (8)
%      -c_1, c_2: Gewichtungsfaktoren des Gütemaßes
%      -alpha, beta: W'keiten der Detektierung (siehe PDF)
%      -options: Optionen der Optimierung

%% Achtung
% -Teilweise gelten Bedingungen für n_n (müssen noch hinzugefügt werden)
% -Die Zustände und Stellgrößen starten zu unterschiedlichen Zeitpunkten
%  aufgrund der vielen Totzeiten

%% Parameter
% Prädiktionshorizont:
n_p = length(r_s);

%% Nebenbedingungen

% linear equality constraints
% Die if Struktur ist noetig, da bei groesseren Praediktionshorizonten
% (n_n) zusaetzliche nichtlineare Nebenbedingungen benoetigt werden, da die
% Zustaende nicht nur von bereits vergangenen Zeitpunkten und den
% Steuergroessen abhaengig sind
if n_n <= k_OV
    beq = [r_s(1,1:n_n)';r_s(2,1:n_n)'];
    %           -u_P*y_TP                    -u_N*y_FN           x_P  
    Aeq_P = [-1*eye(n_n).*y(1,1:n_n), -1*eye(n_n).*y(3,1:n_n),eye(n_n),zeros(n_n)];
    %           -u_P*y_FP                    -u_N*y_TN                    x_N   
    Aeq_N = [-1*eye(n_n).*y(2,1:n_n), -1*eye(n_n).*y(4,1:n_n),zeros(n_n),eye(n_n)];
    Aeq = [Aeq_P; Aeq_N];   
else 
    beq = [r_s(1,1:k_OV)';r_s(2,1:k_OV)'];
    Aeq = zeros(2*k_OV, n_x*n_n+2*k_SO);
    Aeq_P = [-1*eye(k_OV).*y(1,:), zeros(k_OV,n_n-k_OV), -1*eye(k_OV).*y(3,:), zeros(k_OV,n_n-k_OV), ...
        zeros(k_OV,k_SO), eye(k_OV)];
    Aeq_N = [-1*eye(k_OV).*y(2,:),zeros(k_OV,n_n-k_OV), -1*eye(k_OV).*y(4,:), zeros(k_OV,n_n-k_OV), ...
        zeros(k_OV,n_n+2*k_SO), eye(k_OV)];
    Aeq(1:k_OV,1:(2*n_n)+k_SO+k_OV) = Aeq_P;
    Aeq(k_OV+1:2*k_OV,1:(3*n_n)+2*k_SO+k_OV) = Aeq_N;
end
% sparse Matrix ist zeitsparend
Aeq_sparse = sparse(Aeq);
beq_sparse = sparse(beq);
% Nichtlineare Nebenbedingungen
if n_n <= k_OV
    x_opt = fmincon(@(x)guetemass(x,n_n,c_1,c_2,alpha,beta),x0,[],[],Aeq_sparse,beq_sparse,lb,ub,[],options);
else
    x_opt = fmincon(@(x)guetemass(x,n_n,c_1,c_2,alpha,beta),x0,[],[],Aeq_sparse,beq_sparse,lb,ub,@(x)nonlincon(x,r_s, k_OV, k_SO, n_n,alpha,beta),options);
end
end

