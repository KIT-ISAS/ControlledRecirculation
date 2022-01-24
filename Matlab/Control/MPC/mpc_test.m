%% Skript um den MPC zu testen
% Abtastzeit
T = 0.2;
%% Systemparameter
% Totzeiten
tau_SO = 1;
tau_OK = 2;
% Totzeit durch Abstand Kamera Vakuumsauger + Totzeit durch den
% Rückführvorgang
tau_KV = 0.2;
tau_V = 1;
tau_SV = tau_SO + tau_OK + tau_KV + tau_V;
tau_OV = tau_OK + tau_KV + tau_V;
k_SV = int16(tau_SV / T);
k_OV = int16(tau_OV / T);
k_SO = int16(tau_SO / T);
% Wahrscheinlichkeiten
alpha = 0.05;
beta = 0.04;

%% Reglerparameter und Simmulaionsparameter
c_1 = 1;
c_2 = 1;
% Anzahl Zustände
n_x = 4;
% Steuerhorizont
n_n=15;
% letzter Iterationsschritt der Simulation
k_end = 100;

%% Störgrößen usw
r_s = r_s_Simulation;

% Anfangszustände
r_p = zeros(1,length(r_s)+k_SO);
r_n = zeros(1,length(r_s)+k_SO);
r_p(k_SO+1:k_SV+k_SO) = r_s(1,1:k_SV);
r_n(k_SO+1:k_SV+k_SO) = r_s(2,1:k_SV);

r_tp =((1-alpha)*epsi(r_p(1:k_SV+k_SO),r_n(1:k_SV+k_SO)) + alpha*(1-ceta(r_p(1:k_SV+k_SO),r_n(1:k_SV+k_SO)))).*r_p(1:k_SV+k_SO);
r_fp =(beta*epsi(r_p(1:k_SV+k_SO),r_n(1:k_SV+k_SO)) + (1-beta)*(1-ceta(r_p(1:k_SV+k_SO),r_n(1:k_SV+k_SO)))).*r_n(1:k_SV+k_SO);
r_fn =(alpha*ceta(r_p(1:k_SV+k_SO),r_n(1:k_SV+k_SO)) + (1-alpha)*(1-epsi(r_p(1:k_SV+k_SO),r_n(1:k_SV+k_SO)))).*r_p(1:k_SV+k_SO);
r_tn =((1-beta)*ceta(r_p(1:k_SV+k_SO),r_n(1:k_SV+k_SO)) + beta*(1-epsi(r_p(1:k_SV+k_SO),r_n(1:k_SV+k_SO)))).*r_n(1:k_SV+k_SO);

% An Optimierer wird nur eine Matrix mit der Dimension 4 x k_OV übergeben
r_linie_old = [r_tp;r_fp;r_fn;r_tn];
% Ersetzen aller Elemente mit NaN durch 0
r_linie_old(isnan(r_linie_old))=0;
%% Nebenbedingungen
% lower bounds
lb = zeros(1,n_x*n_n)';

% upper bounds
ub_u = ones(1,(2*n_n));
ub = [ub_u Inf*ones(1, (n_x-2)*n_n)]';

%% Optimierungsoptionen
% Optionen
options = optimoptions('fmincon', 'OptimalityTolerance', 1e-3,...
    'StepTolerance', 9.9e-5, 'MaxFunctionEvaluations', 1e6, 'MaxIterations', 1e6, 'ConstraintTolerance', 1e-2);

% Startwert
x_old = 0.5*ones(1,n_x*n_n)';
X = zeros(length(x_old),k_end);
% Optimierung
for i=k_OV+1:k_end
    text_1 = sprintf('----------------- Berechne die optimale Steuergroesse für den Zeitschritt %i -----------------',i);
    disp(text_1)
    x_opt = mpc(r_s(:,i:i+n_n), x_old, r_linie_old(:,i-k_OV:i-1), n_n, k_OV, ...
        k_SO, lb', ub', n_x,c_1,c_2, alpha, beta, options);
%     error = calcError(x_opt, n_n, k_SO, alpha, beta);
%     text_2 = sprintf('Fehler: %f', error);
%     disp(text_2)
    u_p_opt(i) = x_opt(1);
    u_n_pot(i) = x_opt(n_n+1);
    % Ausgänge berechnen
    % müsste es hier nicht vllt i+1+k_SO heißen?
    r_p(i+k_SO) = u_p_opt(i)*r_linie_old(1,i-k_OV) + u_n_pot(i)*r_linie_old(3,i-k_OV) + r_s(1,i)';
    r_n(i+k_SO) = u_p_opt(i)*r_linie_old(2,i-k_OV) + u_n_pot(i)*r_linie_old(4,i-k_OV) + r_s(2,i)';
    y = calcOutput(x_opt,alpha,beta,n_n);
    r_linie_old(1,i+k_SO) = y(1,k_SO); %das hier nochmal überprüfen;
    r_linie_old(2,i+k_SO) =(beta*epsi(r_p(i+k_SO),r_n(i+k_SO)) + (1-beta)*(1-ceta(r_p(i+k_SO),r_n(i+k_SO)))).*r_n(i+k_SO);
    r_linie_old(3,i+k_SO) =(alpha*ceta(r_p(i+k_SO),r_n(i+k_SO)) + (1-alpha)*(1-epsi(r_p(i+k_SO),r_n(i+k_SO)))).*r_p(i+k_SO);
    r_linie_old(4,i+k_SO) =((1-beta)*ceta(r_p(i+k_SO),r_n(i+k_SO)) + beta*(1-epsi(r_p(i+k_SO),r_n(i+k_SO)))).*r_n(i+k_SO);
    % Startvektor für den nächsten Optimierungsschritt
    u_p_start = [x_opt(2:n_n); x_opt(n_n)];
    u_n_start = [x_opt(n_n+2:2*n_n); x_opt(2*n_n)];
    r_p_start = [x_opt(2*n_n+2:3*n_n); x_opt(3*n_n)];
    r_n_start = [x_opt(3*n_n+2:4*n_n); x_opt(4*n_n)];
    x_old = [u_p_start; u_n_start; r_p_start; r_n_start];
    X(:,i) = x_opt;
end