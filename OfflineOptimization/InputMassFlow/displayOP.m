function displayOP(x_opt,delta_J_percentage,delta_J,rP,rN,whichPlot,plo,scale,c,J_opt)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
UP = x_opt(:,:,1);
UN = x_opt(:,:,2);
QP = x_opt(:,:,3);
QN = x_opt(:,:,4);
nP = size(rP,2);
nN = size(rN,2);
RP = zeros(nP,nN);
RN = zeros(nP,nN);
J = zeros(nP,nN);
for ii=1:nP
    for jj=1:nN
        RP(ii,jj) = rP(ii);
        RN(ii,jj) = rN(jj);
        % For calculating the old objective function
        J(ii,jj) = objectiveOP(x_opt(ii,jj,:),scale,c,J_opt);
    end
end

switch whichPlot(1)
    case 'r'
        figure
        surface(RP,RN,delta_J)
        set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
        set(gca,'fontname','times')  % Set it to times
        xlabel('$\overline{r}_{\mathrm{P}}$ in g/s','Interpreter','Latex')
        ylabel('$\overline{r}_{\mathrm{N}}$ in g/s','Interpreter','Latex')
        set(gcf,'color','w');
        caption_1 = 'Absolute increase of objective function for';
        caption_2 = sprintf(' c_{TP}=%0.3f, c_{TN}=%0.3f',c(1),c(4));
        caption_txt = strcat(caption_1,caption_2);
        title(caption_txt)
        colorbar
        xlim([min(rP) max(rP)])
        ylim([min(rN) max(rN)])
    case 'u'
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
        %zlim([0,max(max(delta_J))])
end
shading interp
end


