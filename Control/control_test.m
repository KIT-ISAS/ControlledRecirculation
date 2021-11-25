function [U,U_mpc,T,V,S,Q,q_added,tpr_controlled,tnr_controlled] = control_test(c)
%CONTROL Summary of this function goes here
%   Detailed explanation goes here

%% Parameters
startAt=0;
% We do not want it to stop. Use double to prevent index from becoming
% int, which can cause problems.
endAt=20;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialisierung des MPC
% Massenstrom der Targets und der Massenstrom der No-Targets hin
szenarioFolder = 'Szenario';
% input mass flow in g/s, radius and density
[r_gs,radius,density] = getSzenario(szenarioFolder,c.fileName,c.T);
%% Transform mass flow to particle flow
Volume = zeros(2,1);
% approximated volume of an accept particle in m^3
Volume(1) = 4/3*pi*(radius(1)/1000)^3;
% approximated volume of a reject particle in m^3
Volume(2) = 4/3*pi*(radius(2)/1000)^3;
% input mass flow in particles/s
r_measured(1,:) = r_gs(1,:)/(1000*density(1)*Volume(1));
r_measured(2,:) = r_gs(2,:)/(1000*density(2)*Volume(2));
% Prädiktionshorizont
n_p = size(r_gs,2);
% Anzahl Zustaende
n_x = 4;
% Maximum number of particles on the conveyor belt
qMax = 300;


percentageAccept = 0;
percentageReject = 0;
u = [percentageAccept;percentageReject];

% Use PI as well when using MPC?

k_hat = int16((c.tau_LV + c.tau_KO + c.tau_OL+ c.tau_V+ c.tau_SK)/c.T);
% Steuerhorizont
if isfield(c,'n_n')
    n_n = c.n_n;
else
    n_n = k_hat;
    warning('No control horizon specified: k_hat=%d is the new control horizon',k_hat)
end
x0 = zeros(4*n_n,1);
%Für das Einlesen der Datei, die die zweite Kamera simuliert
% Sortierte_Partikel/Partikel_xxx.txt, mit xxx = Zeitstempel
y_fol='..\Sortierte_Partikel';
y_file = 'Partikel_';

% Initialisierung der Totzeiten und Messvektoren
k_LV        = int16(c.tau_LV/c.T);
k_V         = int16(c.tau_V/c.T);
k_LK        = int16((c.tau_LV + c.tau_V + c.tau_SK)/c.T);
y_measured  = zeros(4,k_LK);
k_KL        = int16((c.tau_KO + c.tau_OL)/c.T);
q_measured  = zeros(2,k_KL);
k_VK        = int16((c.tau_V + c.tau_SK)/c.T);
u_measured  = zeros(2,k_VK);

% Initialisierung des PI des MPC
x_control = zeros(2,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
q0 = r_measured;
% generate artificial measurments
% t in sekunden
deltaT = 0.005;
%Hier Totzeiten für PI-regler
pi_LV = int16(c.tau_LV/deltaT);
pi_VK = int16((c.tau_V + c.tau_SK)/deltaT);
pi_KL = int16((c.tau_KO + c.tau_OL)/deltaT);
U_mpc = zeros(2,endAt/deltaT);
U = zeros(2,endAt/deltaT);
k = 2;
V = zeros(4,endAt/deltaT);
S = zeros(4,endAt/deltaT);
q_added = zeros(2,endAt/deltaT);
M = [1 1 0 0; 0 0 1 1];
N = [1 0 1 0; 0 1 0 1];
Y = zeros(4,endAt/deltaT);
Q = zeros(2,endAt/deltaT);
uMPC = zeros(2,1);
% noise
rng(1002)
noise_yTP = 0.2 + rand(1,endAt/deltaT);
rng(55)
noise_yFP = 0.2 + rand(1,endAt/deltaT);
rng(101)
noise_yFN = 0.2 + rand(1,endAt/deltaT);
rng(20)
noise_yTN = 0.2 + rand(1,endAt/deltaT);
noise_y = [noise_yTP;noise_yFP;noise_yFN;noise_yTN];
rng(7)
rounded_noise_qP = randi(round(r_measured(1)/10),1,endAt/deltaT);
rounded_noise_qN = randi(round(r_measured(2)),1,endAt/deltaT);
rounded_noise_q = [rounded_noise_qP;rounded_noise_qN];
for t=(2*deltaT):deltaT:endAt
    % Set new mesurements
        switch c.type
            case 'PI'
                % Hier kommt der PI Regler hin
%                 percentageAccept = 0;
%                 percentageReject = 0;
            case 'q-P'
                % control law of proportional controller using only the conveyer camera
%                 percentageAccept = c.qP.a*sum_color_accept + c.qP.b*sum_color_reject;
%                 percentageReject = c.qP.c*sum_color_accept + c.qP.d*sum_color_reject;        
            case 'MPC'
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                q = q0 + rounded_noise_q(:,k) + q_added(:,k-1);
                
%                 y = y + rounded_noise_y;
                if k>pi_KL
                    [y,~,~] = calcY(Q(1,k-pi_KL),Q(2,k-pi_KL),1);
                    y = round(noise_y(:,k).*y);
                else
                    y = zeros(4,1);
                end
                Y(:,k) = y;
                Q(:,k) = q;
                % Ab hier wie das System auf die letzte Stellgröße
                % reagiert hat
                if k>pi_LV
                    V(:,k) = round((M'*u).*Y(:,k-pi_LV));
                    S(:,k) = Y(:,k-pi_LV)-V(:,k);
                end
                if k>pi_VK
                    q_added(:,k) = N*V(:,k-pi_VK);
                end
                if mod(t,c.T)==0
                    % Messvektoren werden mit 0en initialisiert und dann wird in jedem
                    % Zeitschritt der älteste Wert gelöscht und der aktuellste neu
                    % eingefügt
                    y_measured(:,1)     = [];
                    y_measured(:,k_LK)  = y;
                    u_measured(:,1)     = [];
                    u_measured(:,k_VK)  = u;
                    q_measured(:,1)     = [];
                    q_measured(:,k_KL)  = q;
                    if n_p > 1
                        % Zufluss wird nicht als konstant angenommen
                        r = r_measured(:,jj:n_p);
                    else
                        % Zufluss wird als konstant angenommen
                        r = r_measured;
                    end
                    [uMPC,x_opt,exitflag,fval] = ...
                        mpcSchuettgut(r, x0, y_measured, q_measured, u_measured,n_n, ...
                        k_hat,k_LV,k_V,k_VK,k_KL,n_x, [c.weights.cTPR 0 0 c.weights.cTNR], c.objective, [0 0],1,qMax);
                    x0 = x_opt;
                    uMPC(1) = min(max(uMPC(1),0),1);
                    uMPC(2) = min(max(uMPC(2),0),1);
                    fprintf('MPC at %0.3f s: -------Accept: %0.5f, Reject: %0.5f-------\n',t,uMPC(1),uMPC(2));
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 'stochastic'
                % Hier kommt der stochastische Regler hin
%                 percentageAccept = 0.5;
%                 percentageReject = 0.5;
            otherwise
                warning('unknown controller type.')
        end
        U_mpc(:,k) = uMPC;
        switch c.type
            case 'MPC'
            if c.PI.use == 1
                % time discrete PI controller as described in [Lunze2020
                % Regelungstechnik 2 p. 524]
                u = -c.PI.kI*x_control -c.PI.kP*(u-uMPC);
                x_control = x_control - uMPC + u;
            else
                u = uMPC;
            end
        end
%         fprintf('-------PI at %0.3f s: Accept: %0.5f, Reject: %0.5f-------\n',t,u(1),u(2));
        U(:,k) = u;
        k = k+1;     
end
T = deltaT:deltaT:endAt;
plot(T,[U;U_mpc]')
tpr_controlled = S(1,:)./(S(1,:)+S(3,:));
tnr_controlled = S(4,:)./(S(4,:)+S(2,:));
end
