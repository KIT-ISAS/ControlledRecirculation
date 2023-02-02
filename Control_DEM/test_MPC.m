function [U,U_mpc,time_error,Q,Q_mpc,exitF,elapsed_time] = test_MPC(c)
%CONTROL sets up the MPC without a simulation.
% Input: The input c is a struct that contains the controller parameters
% and the scenario setup.
% Simply load a controller contained in the folder "Controllers" into the
% workspace and then call this function. 

%% Important
% in all matrices and vectors representing mass flows or particle flows the
% accept particles are in the first row and the reject particles are in the
% second row (e.g. vectors r_measured, q

% in some other vectors it might be vice versa due to the fact that the
% acceptID is chosen as 2. This includes the vectors density, radius, 

% matrices with first dimension equal to 4 often represent mass flows after
% the separation. The order of the rows is following
% [correctly sorted accept; falsely sorted reject; falsely sorted accept; falsely sorted reject]
% [TP; FP; FN; TN] if accept are positive particles and reject are negative

%% Parameters
acceptID = 2;
rejectID = 1;
c.type='MPC';
startAt = 1;
endAt = 30;

%% Initialisierung des MPC
uMPC = zeros(2,1);
list_ID = [];
particles = [];
y_type = [acceptID;rejectID;acceptID;rejectID];
q_type = [acceptID;rejectID];
% Massenstrom der Targets und der Massenstrom der No-Targets hin
szenarioFolder = 'Szenario';
type = [acceptID;rejectID];
% input mass flow in g/s, radius and density
[r_measured,radius,density] = getSzenario(szenarioFolder,c.fileName,c.T,type);

% Praediktionshorizont
n_p = size(r_measured,2);
% number of states
n_x = 4;
% Maximum number of particles on the conveyor belt
if isfield(c,'qMax')
    qMax = c.qMax;
else
    qMax = Inf;
end


percentageAccept = 0;
percentageReject = 0;
u = [percentageAccept;percentageReject];

% Use PI as well when using MPC?
if isfield(c,'PI')
    PI = c.PI.use;
else
    PI = 0;
    warning('No PI controller specified: no PI controller is used when the MPC is used')
end

% time steps needed for a particle for a whole recirculation
k_hat = int16((c.tau_LV + c.tau_KO + c.tau_OL+ c.tau_V+ c.tau_SK)/c.T);

% Steuerhorizont
if isfield(c,'n_n')
    n_n = c.n_n;
else
    n_n = k_hat;
    warning('No control horizon specified: k_hat=%d is the new control horizon',k_hat)
end

% Use filter?
if isfield(c,'filter')
    switch c.filter.type
        case 'mean'
            mean_steps = c.filter.mean.n_steps;
            filter = 'mean';
            q_filter = zeros(2,mean_steps);
        otherwise
            filter = 'off';
    end
else
    warning('No filter specified')
    filter = 'off';
end

x0 = zeros(4*n_n,1);
%Fuer das Einlesen der Datei, die die zweite Kamera simuliert
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
U_mpc = zeros(2,endAt);
U = zeros(2,endAt);
Q = zeros(2,endAt);
Q_mpc = zeros(2,endAt);
time_error = zeros(1,endAt);
exitF = 100*ones(1,endAt);
% Initialisierung des PI des MPC
x_control = zeros(2,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
elapsed_time = zeros(1,endAt);
for t=startAt:endAt
    tic
    % get measurement
    % First Camera
    if n_p > 1
        % Zufluss wird nicht als konstant angenommen
        q = ((rand(2,1)-0.5)/20+1).*r_measured(:,t);
    else
        % Zufluss wird als konstant angenommen
        % hier müsste man eigentlich noch die Totzeit anpassen
        q = ((rand(2,1)-0.5)/20+1).*r_measured;
    end
    Q_mpc(:,t) = q;
    % Second camera
    % scale factor for randomness
    scale = (rand(1,1)-0.5)/10+1;
    y = calcY(q(1),q(2),scale);
    % Messvektoren werden mit 0en initialisiert und dann wird in jedem
    % Zeitschritt der aellteste Wert geloescht und der aktuellste neu
    % eingefuegt
    y_measured(:,1)     = [];
    y_measured(:,k_LK)  = y;
    u_measured(:,1)     = [];
    u_measured(:,k_VK)  = u;
    q_measured(:,1)     = [];
    q_measured(:,k_KL)  = q;
    % reset particle lists and time
    time = 0;
    list_ID = [];
    particles = [];
    % Use filter?
    switch filter
        case 'mean'
            y_measured = movmean(y_measured,mean_steps,2);
    end
    if n_p > 1
        % Zufluss wird nicht als konstant angenommen
        r = r_measured(:,t:n_p);
    else
        % Zufluss wird als konstant angenommen
        r = r_measured;
    end
    [uMPC,x_opt,exitflag,fval] = ...
        mpcSchuettgut(r, x0, y_measured, q_measured, u_measured,n_n, ...
        k_hat,k_LV,k_V,k_VK,k_KL,n_x, [c.weights.cTPR 0 0 c.weights.cTNR], c.objective, [0 0],1,qMax);
    exitF(t) = exitflag;
    x0 = x_opt;
    uMPC(1) = min(max(uMPC(1),0),1);
    uMPC(2) = min(max(uMPC(2),0),1);
    U_mpc(:,t) = uMPC;
    if PI == 1
        % time discrete PI controller as described in [Lunze2020
        % Regelungstechnik 2 p. 524]
        u = -c.PI.kI*x_control -c.PI.kP*(u-uMPC);
        x_control = x_control - uMPC + u;
    else
        u = uMPC;
    end
    U(:,t) = u;
    percentageAccept = u(1);
    percentageReject = u(2);
%     fprintf('Accept percentage %f\n',percentageAccept);
%     fprintf('Reject percentage %f\n',percentageReject);
    elapsed_time(t) = toc;
end
fprintf('max time %f\n',max(elapsed_time));
fprintf('min time %f\n',min(elapsed_time));
fprintf('mean time %f\n',mean(elapsed_time));
end
