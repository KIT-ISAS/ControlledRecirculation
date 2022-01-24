function [uMPC,x_opt,exitflag,fval]  = mpcSchuettgut(r_measured, x0, y_measured, q_measured, u_measured, n_n, k_hat,k_LV,k_V,k_VK,k_KL,n_x, c, opt, q_op,scale,q_max)
%MPC Modellprädiktiver Regler für die Regelung einer Partikelrückführung
%für einen optischen Schüttgutsortierer.
%   Input:
%      -r_s: Matrix mit den Dimensionen 2,P; 
%       Dabei handelt es sich um die Vorhersage wie viele Gutpartikel 
%       (1. Zeile) und wie viele Schlechtpartikel (2. Zeile) von 
%       vorhergegangenen Prozessen auf das Fließband fallen
%      -x0: Optimale Steuergrößenfolge aus der letzten Optimierung, die
%       als Startwert für die kommende Optimierung genutzt wird.
%      -r_linie_old: Matrix mit den Dimensionen 4,1:
%       Anzahl Partikel die pro s zu den letzten k_OV Zeitpunkten auf der 
%       Rutsche fließen aufgeteilt nach:
%           -1. Zeile: Gutpartikel auf der Gutpartikelrutsche (TP)
%           -2. Zeile: Schlechtpartikel auf der Gutpartikelrutsche (FP)
%           -3. Zeile: FN
%           -4. Zeile: TN
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
%      -y_measured : y(k-k_LV-k_VK+1:k)
%      -q_measured : q(k-k_KL+1:k)

%% Achtung
% -Teilweise gelten Bedingungen für n_n (müssen noch hinzugefügt werden)
% -Die Zustände und Stellgrößen starten zu unterschiedlichen Zeitpunkten
%  aufgrund der vielen Totzeiten

%% Optionen
options = optimoptions('fmincon', 'OptimalityTolerance', 1e-3,'Algorithm', 'sqp', ...
    'StepTolerance', 9.9e-5, 'MaxFunctionEvaluations', 1e6, 'MaxIterations', 1e6, 'ConstraintTolerance', 1e-2);
%% Parameter
% Prädiktionshorizont:
n_p = size(r_measured,2);
n_n = int16(n_n);
if n_p < n_n+k_V
    r_predicted = zeros(2,n_n+k_V-n_p);
    r_predicted(1,:) = r_measured(1,n_p)*ones(1,n_n+k_V-n_p);
    r_predicted(2,:) = r_measured(2,n_p)*ones(1,n_n+k_V-n_p);
    r = [r_measured, r_predicted];
else
    r = r_measured;
end
k_hat = int16(k_hat);

%% Prediction
% y_measured1 : y(k-k_LV-k_VK+1:k-k_LV)
y_measured1 = y_measured(:,1:k_VK);
% y_measured2 : y(k-k_LV+1:k)
y_measured2 = y_measured(:,k_VK+1:k_VK+k_LV);
% using old y and u values to predict q
% % q(:,k+1:k+k_VK)   
qP_predicted = u_measured(1,:).*y_measured1(1,:) + u_measured(2,:).*y_measured1(3,:)+ r(1,1:k_VK);
qN_predicted = u_measured(1,:).*y_measured1(2,:) + u_measured(2,:).*y_measured1(4,:)+ r(2,1:k_VK);
% using the functions epsilon and zeta to predict future values of y
% y(:,k+1:k+k_hat)     q(:,k-k_LV+1:k+k_VK)
qP_known = [q_measured(1,:) qP_predicted];
qN_known = [q_measured(2,:) qN_predicted];
y_predicted = calcY(qP_known,qN_known,scale);
%         y(k-k_OV+1:k)  y(k+1:k_hat)
y_known = [y_measured2 y_predicted];
%% Nebenbedingungen
% lower bounds
lb = zeros(1,n_x*n_n)';

% upper bounds
ub_u = ones(1,(2*n_n));

ub = [ub_u q_max*ones(1, (n_x-2)*n_n)]';

% k range for linear constraints
k_lc = size(y_known,2);

if all(n_n > k_hat)
    % r(:,k-k_SK+k_VK+1:k-k_SK+k_VK+k_hat) = r(:,k+k_V+1:k+k_V+k_hat)
    beq = [r(1,k_V+1:k_V+k_hat)';r(2,k_V+1:k_V+k_hat)'];
    %          -u_P*y_TP                                            -u_N*y_FN                                       q_P  
    Aeq_P = [-1*diag(y_known(1,:)), zeros(k_lc,n_n-k_lc), -1*diag(y_known(3,:)) zeros(k_lc,n_n-k_lc) eye(k_lc) zeros(k_lc,2*n_n-k_lc)];
    %          -u_P*y_FP                    -u_N*y_TN                                                                 q_N   
    Aeq_N = [-1*diag(y_known(2,:)), zeros(k_lc,n_n-k_lc), -1*diag(y_known(4,:)), zeros(k_lc,2*n_n-k_lc),eye(k_lc), zeros(k_lc,n_n-k_lc)];
    Aeq = [Aeq_P; Aeq_N];
else
    % r(:,k-k_SK+k_VK+1:k-k_SK+k_VK+n_n) = r(:,k+k_V+1:k+k_V+n_n)
    beq = [r(1,k_V+1:k_V+n_n)';r(2,k_V+1:k_V+n_n)'];
    %          -u_P*y_TP                                            -u_N*y_FN                                       q_P  
    Aeq_P = [-1*diag(y_known(1,:)), zeros(k_lc,n_n-k_lc), -1*diag(y_known(3,:)) zeros(k_lc,n_n-k_lc) eye(k_lc) zeros(k_lc,2*n_n-k_lc)];
    %          -u_P*y_FP                    -u_N*y_TN                                                                 q_N   
    Aeq_N = [-1*diag(y_known(2,:)), zeros(k_lc,n_n-k_lc), -1*diag(y_known(4,:)), zeros(k_lc,2*n_n-k_lc),eye(k_lc), zeros(k_lc,n_n-k_lc)];
    Aeq = [Aeq_P; Aeq_N];
end

if all(n_n > k_hat)
    [x_opt,fval,exitflag,~] = fmincon(@(x)guetemass(x,n_n,k_hat,c, y_known,scale, ...
        opt,k_VK,k_KL,k_LV, q_op),x0,[],[],Aeq,beq,lb,ub,@(x)nonlincon(x,r, k_hat,k_KL, k_LV,k_V,k_VK, n_n, scale),options);
else
    [x_opt,fval,exitflag,~] = fmincon(@(x)guetemass(x,n_n,k_hat,c, y_known,scale, opt,k_VK,k_KL,k_LV, q_op),x0,[],[],Aeq,beq,lb,ub,[],options);
end
u_p = x_opt(1);
u_n = x_opt(n_n+1);
uMPC = [u_p;u_n];
end
