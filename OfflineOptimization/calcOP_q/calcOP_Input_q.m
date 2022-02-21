%% Add characteristics to path
parentDir = fileparts(cd);
grandDir = fileparts(parentDir);
characteristicsDir = strcat(grandDir,'\Kennlinie');
addpath(characteristicsDir)
name1a = 'Data/AP_Berechnung_q_TPR';
nameMAT = '.mat';
% Für eine Maximierung der TPR/TNR müssen folgende Parameter negativ sein
cTP = -0.833;
cFP = 10;
cFN = 10;
cTN = -0.167;
% Genauigkeit des Grids
qP_length = 100;
qN_length = 100;
% Optimization options
options = optimoptions('fmincon','Display','off','Algorithm','interior-point');

rP = 20:10:30;%20:10:80;%5:5:100;
rN = 5:5:10;%5:5:100;
u0 = zeros(2,1);
u_min = zeros(2,1);
u_max = ones(2,1);
rP_length = length(rP);
rN_length = length(rN);
% Initialisierung
u_opt = zeros(rP_length,rN_length,qP_length,qN_length,2);
J_new = zeros(rP_length,rN_length,qP_length,qN_length);
Y = zeros(rP_length,rN_length,qP_length,qN_length,4);
name1c = sprintf('_length=%d',qP_length);
name1 = strcat(name1a,date,name1c);
% Welches Gütemaß?
J_opt = 2;
% skalierung der Kennlinien
scale = 1;
% Open loop TPR/TNR
[R_P,R_N] = meshgrid(rP,rN);
TPR_old = epsilonSeparation(R_P,R_N,scale);
TNR_old = zetaSeparation(R_P,R_N,scale);
tic
for i=1:rP_length
    for j=1:rN_length
        txt = sprintf('-------Accept: %d g/s, Reject: %d g/s-------',rP(i),rN(j));
        disp(txt)
        r = [rP(i) rN(j)];
        qP = linspace(r(1)/2,r(1)*4,qP_length);
        qN = linspace(r(2)/2,r(2)*4,qN_length);
        for k=1:qP_length
            disp(k)
            for n=1:qN_length
                [Y(i,j,k,n,:),~,~] = calcY(qP(k),qN(n),scale);
                % objective function (goal: minimize "objective")
                [u_opt(i,j,k,n,:),J_new(i,j,k,n)] = fmincon(@(u)objectiveOO(u,Y(i,j,k,n,:),r,scale,cTP,cFP,cFN,cTN,J_opt),...
                    u0,[],[],[],[],u_min,u_max,[],options);
            end
        end
        uP_opt = u_opt(i,j,:,:,1);
        uN_opt = u_opt(i,j,:,:,2);
        uP_opt = reshape(uP_opt,qP_length,qN_length);
        uN_opt = reshape(uN_opt,qP_length,qN_length);
        u_opt_max = [max(max(uP_opt));max(max(uN_opt))];
        J_new_ij = reshape(J_new(i,j,:,:),qP_length,qN_length);
        J_old = (cTP*TPR_old+cTN*TNR_old).*ones(rN_length,rP_length,qP_length,qN_length);
        J_old_ij = reshape(J_old(i,j,:,:),qP_length,qN_length);
        % Positive Werte bezeugen Verbesserungen des Gütemaßes
        delta_J_ij = abs(J_new_ij)-abs(J_old_ij);
        name2 = sprintf('_rP=%d_rN=%d',rP(i),rN(j));
        name = strcat(name1,name2,nameMAT);
        save(name,'i','j', 'uP_opt','uN_opt','J_new_ij','J_old_ij','delta_J_ij','qP','qN','-v7.3')
    end
end
switch J_opt
    case 1
        TP = TPR_old.*R_P;
        FP = (1-TNR_old).*R_N;
        FN = (1-TPR_old).*R_P;
        TN = TNR_old.*R_N;
        J_old = cTP*TP+cFP*FP+cFN*FN+cTN*TN;
    case 2
        J_old = cTP*TPR_old + cTN*TNR_old;
end
delta_J = abs(J_new)-abs(J_old);
delta_J_percentage = delta_J./J_old*100;
toc
uP_opt = u_opt(:,:,:,:,1);
uN_opt = u_opt(:,:,:,:,2);
nameAll = strcat(name1,nameMAT);
save(nameAll, '-v7.3')
%% properties for displaying
plo = 'latex';
whichPlot = ['q','uP'];
rP_plot = 30;
rN_plot = 10;
displayGrid(qP,qN,u_opt,delta_J_percentage,delta_J,rP_plot,rN_plot,whichPlot,plo,scale)