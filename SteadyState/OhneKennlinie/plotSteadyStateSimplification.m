%% add to path
parentDir = fileparts(cd);
grandDir = fileparts(parentDir);
characteristicsDir = strcat(grandDir,'\Kennlinie');
addpath(characteristicsDir)
%% settings
scale = 5;
step = 0.005;
saveType = 'png';
axFontSize = 42/scale;
labelFontSize = 68;

%% TPR
fcontour(tpr,[0 1 0 1],'LevelStep',step,'Fill','on')
xlabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
ylabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
% set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
% set(gca,'fontname','times')  % Set it to times
caxis([0 1]);
% save as pdf
prepareFig([6,6],scaling=scale,fontSize=axFontSize); 
ax=gca; 
% ax.FontSize = axFontSize;
ax.XLabel.FontSize = labelFontSize; 
ax.YLabel.FontSize = labelFontSize;
set(gca,'TickLength',[0 0])
yticks([0 0.2 0.4 0.6 0.8 1])
xticks([0 0.2 0.4 0.6 0.8 1])
xticklabels({'$0$','$0.2$','$0.4$','$0.6$','$0.8$','$1$'})
allText = findall(gca, 'Type', 'Text');
allAxes = findall(gcf, 'Type', 'Axes');
set(allAxes, 'ticklabelinterpreter', 'latex');
set(allText(isvalid(allText)), 'interpreter', 'latex');
saveas(gcf,'TPR_simple', saveType)
close
%% TNR
fcontour(tnr,[0 1 0 1],'LevelStep',step,'Fill','on')
xlabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
ylabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
% set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
% set(gca,'fontname','times')  % Set it to times
caxis([0 1]);
% save as pdf
prepareFig([6,6],scaling=scale,fontSize=axFontSize); 
ax=gca; 
% ax.FontSize = axFontSize;
ax.XLabel.FontSize = labelFontSize; 
ax.YLabel.FontSize = labelFontSize;
set(gca,'TickLength',[0 0])
yticks([0 0.2 0.4 0.6 0.8 1])
xticks([0 0.2 0.4 0.6 0.8 1])
xticklabels({'$0$','$0.2$','$0.4$','$0.6$','$0.8$','$1$'})
allText = findall(gca, 'Type', 'Text');
allAxes = findall(gcf, 'Type', 'Axes');
set(allAxes, 'ticklabelinterpreter', 'latex');
set(allText(isvalid(allText)), 'interpreter', 'latex');
saveas(gcf,'TNR_simple', saveType)
close
%% J
figure
fcontour(J,[0 1 0 1],'LevelStep',step,'Fill','on')
xlabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
ylabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
caxis([0 1]);
txt = '$\overline{u}_{\mathrm{N}}^* = \frac{3}{2}\overline{u}_{\mathrm{P}}^*-\frac{1}{2}\rightarrow$';
hold on
if e>z
    fplot(uN_opt,[double(uP_min) 0.98], '--k', 'LineWidth',3)
    txt = '$\overline{u}_{\mathrm{N}}^* = 0.8123\overline{u}_{\mathrm{P}}^*+0.1877\rightarrow$';
    alignment = 'right';
    x = 0.8;
    y=0.7;
else
    fplot(uN_opt,[0 0.98], '--k', 'LineWidth',3)
    txt = '$\quad\overline{u}_{\mathrm{N}}^* = 0.812\overline{u}_{\mathrm{P}}^*+0.188$';
    alignment = 'left';
    x = 0.1;
    y=double(subs(uN_opt,x));
end
hold off
% save as pdf
prepareFig([6,6],scaling=scale,fontSize=axFontSize); 
ax=gca; 
% ax.FontSize = axFontSize;
ax.XLabel.FontSize = labelFontSize; 
ax.YLabel.FontSize = labelFontSize;
set(gca,'TickLength',[0 0])
yticks([0 0.2 0.4 0.6 0.8 1])
xticks([0 0.2 0.4 0.6 0.8 1])
xticklabels({'$0$','$0.2$','$0.4$','$0.6$','$0.8$','$1$'})
prepareFig([6,6],scaling=scale,fontSize=axFontSize); 
ax.XLabel.FontSize = labelFontSize; 
ax.YLabel.FontSize = labelFontSize;
set(gca,'TickLength',[0 0])
yticks([0 0.2 0.4 0.6 0.8 1])
xticks([0 0.2 0.4 0.6 0.8 1])
xticklabels({'$0$','$0.2$','$0.4$','$0.6$','$0.8$','$1$'})
text(x,y,txt,'Interpreter','Latex','FontSize',42,'HorizontalAlignment',alignment)
allText = findall(gca, 'Type', 'Text');
allAxes = findall(gcf, 'Type', 'Axes');
set(allAxes, 'ticklabelinterpreter', 'latex');
set(allText(isvalid(allText)), 'interpreter', 'latex');
saveas(gcf,'J_simple', saveType)
