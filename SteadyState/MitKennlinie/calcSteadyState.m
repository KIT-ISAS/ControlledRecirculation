clear
% Add Characteristics to path
parentDir = fileparts(cd);
grandDir = fileparts(parentDir);
characteristicsDir = strcat(grandDir,'\Kennlinie');
addpath(characteristicsDir)
% cTP und cTN sollten positiv sein, damit man es vergleichen kann mit Fig.4
cTP = 0.5;
cFP = -10;
cFN = -10;
cTN = 0.5;
c = [cTP cFP cFN cTN];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choose incoming mass flow
rP = 90;%10:delta_rP:20;
rN = 10;%5:delta_rP:10;
r = [rP; rN];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 1. Span the grid
%Genauigkeit des Grids
delta_uP = 0.01;
delta_uN = 0.01;
% maximum values of the grid
uP_max = 0.95;
uN_max = 0.95;
% grid
uP = 0:delta_uP:uP_max;
uN = 0:delta_uN:uN_max;
nUP = size(uP,2);
nUN = size(uN,2);
% scale the characteristics?
scale = 1;
%% 2. Calculate q numerically by solving an optimization problem
% Optimization options %
options = optimoptions('fmincon','Display','off','Algorithm','interior-point','StepTolerance',1e-3,'OptimalityTolerance',1e-3);
% constraints
q0 = r.*ones(2,1);
q_min = zeros(2,1);
q_max = Inf*ones(2,1);
uP_fit = zeros(nUP*nUN,1);
uN_fit = zeros(nUP*nUN,1);
qP_fit = zeros(nUP*nUN,1);
qN_fit = zeros(nUP*nUN,1);
q_approx_ij = zeros(nUP,nUN,2);
q_error_ij = zeros(nUP,nUN);
exit_ij = zeros(nUP,nUN);
a = 1;
for k=1:nUP
    txt = sprintf('-------uP: %d -------',uP(k));
    disp(txt)
    for n=1:nUN
        u = [uP(k);uN(n)];
        % vector for fitting qP and qP
        uP_fit(a) = uP(k);
        uN_fit(a) = uN(n);
        % objective function (goal: minimize approximating error of qP and qN)
        [q0,q_error,exitF,~] = fmincon(@(q)objectiveCalc_q(q,u,r,scale),...
            q0,[],[],[],[],q_min,q_max,[],options);
        q_approx_ij(k,n,:) = q0;
        q_error_ij(k,n) = q_error;
        exit_ij(k,n) = exitF;
%                 max_error = max(max(q_error));
%                 mean_error = mean(q_error);
%                 txt = sprintf('-------Maximum error: %i, Mean: %i-------',max_error,mean_error);
%                 disp(txt) 
        qP_fit(a) = q0(1);
        qN_fit(a) = q0(2);
        a = a+1;
    end
end
%% 3. fit the two functions
% fit qP and qN (might need severals runs since starting point is chosen randomly
qP_fitted = fit([uP_fit, uN_fit],qP_fit,'a*exp(b^x)+c*x+d*x^2+e*y+f*y^2+g*exp(h^y)*exp(k^y)');
qN_fitted = fit([uP_fit, uN_fit],qN_fit,'a*exp(b^x)+c*x+d*x^2+e*y+f*y^2+g*exp(h^y)*exp(k^x)');
% symbolic function qp(up,un);
qp = subs(str2sym(formula(qP_fitted)),coeffnames(qP_fitted),num2cell(coeffvalues(qP_fitted).'));
% variables up and un from now on called x and y
vars = sym(indepnames(qP_fitted));
% symbolic function qn(up,un);
qn = subs(str2sym(formula(qN_fitted)),coeffnames(qN_fitted),num2cell(coeffvalues(qN_fitted).'));
[y_tp,y_fp,y_fn,y_tn] = calcY_symbolic(qp,qn,scale);
%% 4. Calculate TPR/TNR and objective function
% represents the vector valued function s (mass flows after
% recirculation)
tp = (1-vars(1))*y_tp;
fp = (1-vars(1))*y_fp;
fn = (1-vars(2))*y_fn;
tn = (1-vars(2))*y_tn;
% tpr and tnr
tpr = tp/(tp+fn);
tnr = tn/(tn+fp);
J = cTP*tpr+cTN*tnr;
