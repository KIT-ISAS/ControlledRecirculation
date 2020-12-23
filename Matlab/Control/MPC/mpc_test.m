%% Skript um den MPC zu testen

% Abtastzeit
T = 0.1;
% Anzahl Zustände
n_x = 8;
% Steuerhorizont
n_n=35;
%% Systemparameter
% Totzeiten
tau_SO = 1.1;
tau_OK = 2;
% Totzeit durch Abstand Kamera Vakuumsauger + Totzeit durch den
% Rückführvorgang
tau_KV = 1.2;
tau_SV = tau_SO + tau_OK + tau_KV;
tau_OV = tau_OK + tau_KV;
k_SV = int16(tau_SV / T);
k_OV = int16(tau_OV / T);
k_SO = int16(tau_SO / T);
% Wahrscheinlichkeiten
alpha = 0.05;
beta = 0.04;
% reglerparameter
c_1 = 1;
c_2 = 1;

%% Störgrößen usw
% Gutpartikel die auf das Fließband fallen (Störgröße bzw. Verbindung mit der Umwelt)
r_sp = 100*[0.7*ones(1,200) 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.8 0.81 0.83 0.85 0.9*ones(1,100) 0.85 0.83 0.81 0.78 0.75 0.7 0.65 0.6 0.58 0.53 0.5*ones(1,50)];
% verrauschtes Signal
r_sp = awgn(r_sp,35,'measured');
r_sn = 100-r_sp;
r_s = [r_sp; r_sn];
r_s = [r_s zeros(2,300)];

% Anfangszustände
r_p = zeros(1,length(r_sp)+k_SO);
r_n = zeros(1,length(r_sp)+k_SO);
r_p(k_SO+1:k_SV+k_SO) = r_sp(1:k_SV);
r_n(k_SO+1:k_SV+k_SO) = r_sn(1:k_SV);

r_tp =((1-alpha)*epsi(r_p(1:k_OV),r_n(1:k_OV)) + alpha*(1-ceta(r_p(1:k_OV),r_n(1:k_OV)))).*r_p(1:k_OV);
r_fp =(beta*epsi(r_p(1:k_OV),r_n(1:k_OV)) + (1-beta)*(1-ceta(r_p(1:k_OV),r_n(1:k_OV)))).*r_n(1:k_OV);
r_fn =(alpha*ceta(r_p(1:k_OV),r_n(1:k_OV)) + (1-alpha)*(1-epsi(r_p(1:k_OV),r_n(1:k_OV)))).*r_p(1:k_OV);
r_tn =((1-beta)*ceta(r_p(1:k_OV),r_n(1:k_OV)) + beta*(1-epsi(r_p(1:k_OV),r_n(1:k_OV)))).*r_n(1:k_OV);
% An Optimierer wird nur eine Matrix mit der Dimension 4 x k_OV übergeben
r_linie_old = [r_tp;r_fp;r_fn;r_tn];
r_linie_old(isnan(r_linie_old))=0;
%% Nebenbedingungen
% lower bounds
lb = zeros(1,n_x*n_n+2*k_SO)';

% upper bounds
ub_u = ones(1,2*n_n);
ub = [ub_u Inf*ones(1, (n_x-2)*n_n+2*k_SO)]';

%% Optimierungsoptionen
options = optimoptions('fmincon', 'OptimalityTolerance', 1e-5,...
    'StepTolerance', 9.9e-16, 'MaxFunctionEvaluations', 1e6, 'MaxIterations', 1e6, 'ConstraintTolerance', 1e-5);

% Startwert
x_old = 0.5*ones(1,n_x*n_n+2*k_SO)';
% Hier muss noch der Index von r_line_old angepasst werden
for i=1:200
    x_opt = mpc(r_s(:,i:i+n_n), x_old, r_linie_old(:,i:i+k_OV), n_n, k_OV, ...
        k_SO, lb', ub', n_x,c_1,c_2, alpha, beta, options);
    u_p_opt(i) = x_opt(1);
    u_n_pot(i) = x_opt(n_n+1);
    % Ausgänge berechnen
    r_p(k_OV+1:n_n) = u_p(k_OV+1:n_n).*r_TP(1:n_n-k_OV) + u_n(k_OV+1:n_n).*r_FN(1:n_n-k_OV) + r_s(1,k_OV+1:n_n)';
    r_n(k_OV+1:n_n) = u_p(k_OV+1:n_n).*r_FP(1:n_n-k_OV) + u_n(k_OV+1:n_n).*r_TN(1:n_n-k_OV) + r_s(2,k_OV+1:n_n)';
    

    % Startvektor für den nächsten Optimierungsschritt
    u_p_start = [x_opt(2:n_n); x_opt(n_n)];
    u_n_start = [x_opt(n_n+2:2*n_n); x_opt(2*n_n)];
    r_p_start = [x_opt(2*n_n+2:3*n_n+k_SO); x_opt(3*n_n+k_SO)];
    r_n_start = [x_opt(3*n_n+k_SO+2:4*n_n+2*k_SO); x_opt(4*n_n+2*k_SO)];
    r_tp_start = [x_opt(4*n_n+2*k_SO+2:5*n_n+2*k_SO); x_opt(5*n_n+2*k_SO)];
    r_fp_start = [x_opt(5*n_n+2*k_SO+2:6*n_n+2*k_SO); x_opt(6*n_n+2*k_SO)];
    r_fn_start = [x_opt(6*n_n+2*k_SO+2:7*n_n+2*k_SO); x_opt(7*n_n+2*k_SO)];
    r_tn_start = [x_opt(7*n_n+2*k_SO+2:8*n_n+2*k_SO); x_opt(8*n_n+2*k_SO)];
    x_old = [u_p_start; u_n_start; r_p_start; r_n_start; r_tp_start; r_fp_start; r_fn_start; r_tn_start];
    X(:,i) = x_opt;
end