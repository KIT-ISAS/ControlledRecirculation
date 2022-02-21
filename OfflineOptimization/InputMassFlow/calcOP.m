%% Add characteristics to path
parentDir = fileparts(cd);
grandDir = fileparts(parentDir);
characteristicsDir = strcat(grandDir,'\Kennlinie');
addpath(characteristicsDir)
%% properties for displaying
plo = 'latex';
whichPlot = ['r','deltaJ'];
%% objective function
% Two different objective functions are implemented (see objectiveOP)
% the first one (J_opt=1) maximizes the mass flow of the TP and TN and 
% minimizes the mass flow of the FP and FN
% The second one (J_opt=2) maximizes the TPR and TNR
J_opt = 2;
%% coefficients of the objective function
% if you want to maximize the TPR and TNR, cTP and cTN have to be negative
cTP = -0.167;
cTN = -0.833;
% cFP and cFN should be positive but are only used if J_opt=1
cFP = 10;
cFN = 10;
c = [cTP cFP cFN cTN];
%% Optimization options
options = optimoptions('fmincon','Display','off','Algorithm','interior-point');
% start values and inequality constraints
x0 = zeros(4,1);
x_min = zeros(4,1);
x_max = [ones(2,1); Inf*ones(2,1)];
%% Properties of the grid
delta_rP = 5;
delta_rN = 5;
rP = 10:delta_rP:100;
rN = 5:delta_rP:80;
% would you like to scale the characteristics? If yes, "scale" is the scaling
% factor. Choose scale=1 if no scaling is needed
scale = 1;
% uP, uN, qP, qN
x_opt = zeros(length(rP),length(rN),4);
J_old = zeros(length(rP),length(rN));
J_new = zeros(length(rP),length(rN));
tic
for ii=1:length(rP)
    for jj=1:length(rN)
        txt = sprintf('-------Accept: %d g/s, Reject: %d g/s-------',rP(ii),rN(jj));
        disp(txt)
        r = [rP(ii);rN(jj)];
        % For calculating the old objective function
        x_old = [zeros(2,1);rP(ii);rN(jj)];
        J_old(ii,jj) = objectiveOP(x_old,scale,c,J_opt);
        % objective function (goal: minimize "objective")
        [x_opt(ii,jj,:),J_new(ii,jj)] = fmincon(@(x)objectiveOP(x,scale,c,J_opt),...
            x0,[],[],[],[],x_min,x_max,@(x)nonlinconOP(x,r,scale),options);
    end
end
uP_opt = x_opt(:,:,1);
uN_opt = x_opt(:,:,2);
qP_opt = x_opt(:,:,3);
qN_opt = x_opt(:,:,4);
% Positive Werte bezeugen Verbesserungen des Gütemaßes
delta_J = abs(J_new)-abs(J_old);
delta_J_percentage = delta_J./J_old*100;
toc
displayOP(x_opt,delta_J_percentage,delta_J,rP,rN,whichPlot,plo,scale,c,J_opt)