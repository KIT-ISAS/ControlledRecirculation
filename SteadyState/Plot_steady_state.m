clear
syms e z u_p u_n real positive
tpr = e*(1-u_p)./(1-(u_p-u_n)*e-u_n);
tnr = z*(1-u_n)./(1-(u_n-u_p)*z-u_p);
e = 0.9;
z = 0.8;
tpr_s = subs(tpr);
tnr_s = subs(tnr);
sum_rate =subs(tpr+tnr);
J =(tpr_s + tnr_s);
eqP = diff(J,u_p) == 0;
eqN = diff(J,u_n) == 0;
constraints = [u_p<=1, u_n <=1];
[uP_opt,uN_opt,parameters,conditions] = solve([eqP,eqN,constraints],[u_p,u_n],'ReturnConditions', true);
% syms optimal_uP
% uN_dependent_uP = solve(optimal_uP==uP_opt,parameters);
% u_N_min = solve(uN_dependent_uP,optimal_uP);
p_type = 'sum';
switch p_type
    case 'tpr'
        figure
        fcontour(tpr_s,[0 1 0 1],'LevelStep',0.001,'Fill','on')
        xlabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
        ylabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
        set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
        set(gca,'fontname','times')  % Set it to times
%         title 'Static True Positive Rate'
        colorbar
    case 'tnr'
        figure
        fcontour(tnr_s,[0 1 0 1],'LevelStep',0.001,'Fill','on')
        xlabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
        ylabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
        set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
        set(gca,'fontname','times')  % Set it to times
%         title 'Static True Negative Rate'
        colorbar
    case 'sum'
        figure
        fcontour(sum_rate,[0 1 0 1],'LevelStep',0.001,'Fill','on')
        xlabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
        ylabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
        colorbar
        hold on
        fplot(uP_opt,[0 0.98], '--r', 'LineWidth',3)
        hold off
        set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
        set(gca,'fontname','times')  % Set it to times
end