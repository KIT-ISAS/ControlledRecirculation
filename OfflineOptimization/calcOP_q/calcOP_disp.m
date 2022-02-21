%
plo = 'latex';
whichPlot = ['u','deltaJ'];
% Für eine Maximierung der TPR/TNR müssen folgende Parameter negativ sein
cTP = -0.5;%-0.833;
cFP = 10;
cFN = 10;
cTN = -0.5;%-0.167;
% Optimization options
options = optimoptions('fmincon','Display','off','Algorithm','interior-point');
%Genauigkeit des Grids
deltaQ = 1;
rP = 20;%20:10:80;%5:5:100;
rN = 10;%5:5:100;
r = [rP;rN];
u0 = zeros(2,1);
u_min = zeros(2,1);
u_max = ones(2,1);
% Welches Gütemaß?
J_opt = 2;
% skalierung der Kennlinien
scale = 1;
% Open loop TPR/TNR
TPR_old = epsilonSeparation(rP,rN,scale);
TNR_old = zetaSeparation(rP,rN,scale);
qP_max = 50*rP;
qN_max = 50*rN;
qP = rP:deltaQ:qP_max;
qN = rN:deltaQ:qN_max;
Y = zeros(length(qP),length(qN),4);
u_opt = zeros(length(qP),length(qN),2);
J_new = zeros(length(qP),length(qN));
tic
for k=1:length(qP)
    disp(k)
    for n=1:length(qN)
        [Y(k,n,:),~,~] = calcY(qP(k),qN(n),scale);
        % objective function (goal: minimize "objective")
        [u_opt(k,n,:),J_new(k,n)] = fmincon(@(u)objectiveOO(u,Y(k,n,:),r,scale,cTP,cFP,cFN,cTN,J_opt),...
            u0,[],[],[],[],u_min,u_max,[],options);
    end
end
uP_opt = u_opt(:,:,1);
uN_opt = u_opt(:,:,2);
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
% Positive Werte bezeugen Verbesserungen des Gütemaßes
delta_J = abs(J_new)-abs(J_old);
delta_J_percentage = delta_J./J_old*100;
toc
displayGrid(qP,qN,u_opt,delta_J_percentage,delta_J,rP,rN,whichPlot,plo,scale)