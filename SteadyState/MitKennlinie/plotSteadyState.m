%% add path
parentDir = fileparts(cd);
grandDir = fileparts(parentDir);
addpath(grandDir)
%% settings
scale = 5;
step = 0.1;
saveType = 'png';
axFontSize = 42/scale;
labelFontSize = 68;
fontName = 'Times';
%% TPR
fcontour(tpr,[0 1 0 1],'LevelStep',step,'Fill','on')
%         fsurf(tpr,[0 0.8 0 0.8])
xlabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
ylabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
% set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
% set(gca,'fontname','times')  % Set it to times
caxis([0 1]);
% save as pdf
prepareFig([6,6],scaling=scale,fontSize=axFontSize); 
ax=gca; 
ax.FontSize = axFontSize;
ax.XLabel.FontSize = labelFontSize; 
ax.YLabel.FontSize = labelFontSize;
set(gca,'TickLength',[0 0])
yticks([0 0.2 0.4 0.6 0.8 1])
xticks([0 0.2 0.4 0.6 0.8 1])
xticklabels({'0','0.2','0.4','0.6','0.8','1'})
allText = findall(gca, 'Type', 'Text');
allAxes = findall(gcf, 'Type', 'Axes');
set(allAxes, 'ticklabelinterpreter', 'latex');
set(allText(isvalid(allText)), 'interpreter', 'latex');
saveas(gcf,'TPR', saveType)
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
xticklabels({'0','0.2','0.4','0.6','0.8','1'})
allText = findall(gca, 'Type', 'Text');
allAxes = findall(gcf, 'Type', 'Axes');
set(allAxes, 'ticklabelinterpreter', 'latex');
set(allText(isvalid(allText)), 'interpreter', 'latex');
saveas(gcf,'TNR', saveType)
close
%% J
fcontour(J,[0 1 0 1],'LevelStep',step,'Fill','on')
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
xticklabels({'0','0.2','0.4','0.6','0.8','1'})
allText = findall(gca, 'Type', 'Text');
allAxes = findall(gcf, 'Type', 'Axes');
set(allAxes, 'ticklabelinterpreter', 'latex');
set(allText(isvalid(allText)), 'interpreter', 'latex');
saveas(gcf,'J', saveType)