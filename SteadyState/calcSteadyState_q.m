clear
plo = 'latex';
% Optionen: qP, qN, TPR, TNR, J
whichPlot = 'qP-fit';
% Für eine Maximierung der TPR/TNR müssen folgende Parameter negativ sein
cTP = 0.5;%-0.833;
cFP = -10;
cFN = -10;
cTN = 0.5;%-0.167;
c = [cTP cFP cFN cTN];
% Optimization options
options = optimoptions('fmincon','Display','off','Algorithm','interior-point','OptimalityTolerance',1e-6);
%Genauigkeit des Grids
% rP and rN can not be part of the grid so far
delta_rP = 10;
delta_rN = 5;
delta_uP = 0.01;
delta_uN = 0.01;
uP_max = 0.9;
uN_max = 0.9;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% hier rP und rN einstellen
rP = 20;%10:delta_rP:20;
rN = 10;%5:delta_rP:10;
r = [rP; rN];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
uP = 0:delta_uP:uP_max;
uN = 0:delta_uN:uN_max;
nRP = size(rP,2);
nRN = size(rN,2);
nUP = size(uP,2);
nUN = size(uN,2);
%Initialisierung
q0 = r.*ones(2,1);
q_min = zeros(2,1);
q_max = Inf*ones(2,1);
% skalierung der Kennlinien
scale = 1;
q_approx = zeros(nRP,nRN,nUP,nUN,2);
q_error = zeros(nRP,nRN,nUP,nUN);
uP_fit = zeros(nUP*nUN,1);
uN_fit = zeros(nUP*nUN,1);
qP_fit = zeros(nUP*nUN,1);
qN_fit = zeros(nUP*nUN,1);
for ii=1:nRP
    for jj=1:nRN
        txt = sprintf('-------Accept: %d g/s, Reject: %d g/s-------',rP(ii),rN(jj));
        disp(txt)
        r = [rP(ii); rN(jj)];
        q_approx_ij = zeros(nUP,nUN,2);
        q_error_ij = zeros(nUP,nUN);
        a = 1;
        for k=1:nUP
            for n=1:nUN
                u = [uP(k);uN(n)];
                % vector for fitting qP and qP
                uP_fit(a) = uP(k);
                uN_fit(a) = uN(n);
                % objective function (goal: minimize approximating error of qP and qN)
                [q0,q_error] = fmincon(@(q)objectiveCalc_q(q,u,r,scale),...
                    q0,[],[],[],[],q_min,q_max,[],options);
%                 q_approx(ii,jj,k,n,:) = q0;
                q_approx_ij(k,n,:) = q0;
%                 q_error(ii,jj,k,n) = q_error;
                q_error_ij(k,n) = q_error;
                max_error = max(max(q_error));
                mean_error = mean(q_error);
                txt = sprintf('-------Maximum error: %i, Mean: %i-------',max_error,mean_error);
                disp(txt) 
                qP_fit(a) = q0(1);
                qN_fit(a) = q0(2);
                a = a+1;
            end
        end
        % fit qP and qN
        qP_fitted = fit([uP_fit, uN_fit],qP_fit,'poly55');
        qN_fitted = fit([uP_fit, uN_fit],qN_fit,'poly55');
        % symbolic function qp(up,un);
        qp = subs(str2sym(formula(qP_fitted)),coeffnames(qP_fitted),num2cell(coeffvalues(qP_fitted).'));
        % variables up and un from now on called x and y
        vars = sym(indepnames(qP_fitted));
        % symbolic function qn(up,un);
        qn = subs(str2sym(formula(qN_fitted)),coeffnames(qN_fitted),num2cell(coeffvalues(qN_fitted).'));
        [y_tp,y_fp,y_fn,y_tn] = calcY_symbolic(qp,qn,scale);
        % represents the vector valued function s (mass flows after
        % recirculation)
        tp = (1-vars(1))*y_tp;
        fp = (1-vars(1))*y_fp;
        fn = (1-vars(2))*y_fn;
        tn = (1-vars(2))*y_tn;
        % tpr and tnr
        tpr = tp/(tp+fn);
        tnr = tn/(tn+fp);
        % objective function
        J = cTP*tpr+cTN*tnr;
%         vars = sym(indepnames(qN_fitted));
        dJdP = diff(J, vars(1));
        dJdN = diff(J, vars(2));
    end
end
switch whichPlot
    case 'qP-fit'
        plot( qP_fitted, [uP_fit, uN_fit],qP_fit )
        xlabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
        ylabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
        zlabel('$\overline{q}_{\mathrm{P}}$','Interpreter','Latex')
        set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
        set(gca,'fontname','times')  % Set it to times
        xlim([0 1])
        ylim([0 1])
    case 'qP'
        fcontour(qp,[0 1 0 1],'LevelStep',0.1,'Fill','on')
        xlabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
        ylabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
        zlabel('$\overline{q}_{\mathrm{P}}$','Interpreter','Latex')
        set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
        set(gca,'fontname','times')  % Set it to times
    case 'qN-fit'
        plot( qN_fitted, [uP_fit, uN_fit],qN_fit )
        xlabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
        ylabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
        zlabel('$\overline{q}_{\mathrm{N}}$','Interpreter','Latex')
        set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
        set(gca,'fontname','times')  % Set it to times
        xlim([0 1])
        ylim([0 1])
    case 'qN'
        fcontour( qN, [uP_fit, uN_fit],qN_fit )
        xlabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
        ylabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
        zlabel('$\overline{q}_{\mathrm{N}}$','Interpreter','Latex')
        set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
        set(gca,'fontname','times')  % Set it to times
    case 'TPR'
        fcontour(tpr,[0 1 0 1],'LevelStep',0.1,'Fill','on')
%         fsurf(tpr,[0 0.8 0 0.8])
        xlabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
        ylabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
        set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
        set(gca,'fontname','times')  % Set it to times
        title 'TPR'
        colorbar
    case 'TNR'
        fcontour(tnr,[0 1 0 1],'LevelStep',0.01,'Fill','on')
        xlabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
        ylabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
        set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
        set(gca,'fontname','times')  % Set it to times
        title 'TNR'
        colorbar
    case 'J'
        fcontour(J,[0 1 0 1],'LevelStep',0.01,'Fill','on')
        xlabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
        ylabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
        set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
        set(gca,'fontname','times')  % Set it to times
        title 'TNR'
        colorbar
end