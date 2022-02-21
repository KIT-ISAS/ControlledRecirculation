function displayGrid(qP,qN,u_opt,delta_J_percentage,delta_J,rP_plot,rN_plot,whichPlot,plo,scale)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
uP_opt = u_opt(:,:,1);
uN_opt = u_opt(:,:,2);
epsilon = zeros(length(qP),length(qN));
zeta = zeros(length(qP),length(qN));
QP = zeros(length(qP),length(qN));
QN = zeros(length(qP),length(qN));
for k=1:length(qP)
    for n=1:length(qN)
        QP(k,n) = qP(k);
        QN(k,n) = qN(n);
        [~,epsilon(k,n,:),zeta(k,n,:)] = calcY(qP(k),qN(n),scale);
    end
end 
switch whichPlot(1)
    case 'q'
        switch whichPlot(2)
            case 'uP'
                uP_opt = round(uP_opt,2);
                if plo == "latex"
                    figure
                    surface(QP,QN,uP_opt)
                    set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
                    set(gca,'fontname','times')  % Set it to times
                else
                    caption_txt = sprintf('u_P for c_{TPR}=%d, c_{TNR}=%d, r_P=%d, r_N=%d',cTP,cTN,rP_plot, rN_plot);
                    surface(QP,QN,uP_opt_ij)
                    title(caption_txt)
                end
            case 'uN'
                uN_opt = round(uN_opt,2);
                if plo == "latex"
                    figure
                    surface(QP,QN,uN_opt)
                    set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
                    set(gca,'fontname','times')  % Set it to times
                else
                    caption_txt = sprintf('u_N for c_{TPR}=%d, c_{TNR}=%d, r_P=%d, r_N=%d',cTP,cTN,rP_plot, rN_plot);
                    surface(QP,QN,uN_opt)        
                    title(caption_txt)
                end
            case 'deltaJ'
                delta_J = round(delta_J,2,'significant');
                if plo == "latex"
                    figure
                    surface(QP,QN,delta_J)
                    set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
                    set(gca,'fontname','times')  % Set it to times
                else
                    caption_txt = sprintf('Increase of objective function for c_{TPR}=%d, c_{TNR}=%d, r_P=%d, r_N=%d',cTP,cTN,rP_plot, rN_plot);
                    surface(QP,QN,delta_J)
                    title(caption_txt)
                end
            case 'deltaJperc'
                delta_J_percentage = round(delta_J_percentage,2,'significant');
                if plo == "latex"
                    figure
                    surface(QP,QN,delta_J_percentage)
                    set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
                    set(gca,'fontname','times')  % Set it to times
                else
                    caption_txt = sprintf('Increase of objective function for c_{TPR}=%d, c_{TNR}=%d, r_P=%d, r_N=%d',cTP,cTN,rP_plot, rN_plot);
                    surface(QP,QN,delta_J_percentage)
                    title(caption_txt)
                end
        end
        xlabel('$\overline{q}_{\mathrm{P}}$ in g/s','Interpreter','Latex')
        ylabel('$\overline{q}_{\mathrm{N}}$ in g/s','Interpreter','Latex')
        set(gcf,'color','w');
        colorbar
        xlim([rP_plot max(qP)])
        ylim([rN_plot max(qN)])
    case 'u'
        UP = (((epsilon + zeta - 1).*QN - rN_plot*(epsilon - 1)).*QP - rP_plot*QN.*zeta)./(QN.*QP.*(epsilon + zeta - 1));
        UN = (((epsilon + zeta - 1).*QP - rP_plot*(zeta - 1)).*QN - rN_plot*epsilon.*QP)./(QN.*QP.*(epsilon + zeta - 1));
        figure
        surface(UP,UN,delta_J)
        set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
        set(gca,'fontname','times')  % Set it to times
        xlabel('$\overline{u}_{\mathrm{P}}$ in g/s','Interpreter','Latex')
        ylabel('$\overline{u}_{\mathrm{N}}$ in g/s','Interpreter','Latex')
        set(gcf,'color','w');
        colorbar
        xlim([0 1])
        ylim([0 1])
        zlim([0,max(max(delta_J))])
end
shading interp
end


