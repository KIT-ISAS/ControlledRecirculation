%% settings
scale = 5;
step = 0.1;
saveType = 'png';
axFontSize = 42/scale/0.333*0.15;
labelFontSize = 68;

%% TPR
f=fcontour(tpr,[0 1 0 1],'LevelStep',step,'Fill','on')
xlabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
ylabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
% set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
% set(gca,'fontname','times')  % Set it to times
caxis([0 1]);
cb=colorbar('northoutside');
% save as pdf
prepareFig([6,6],scaling=scale,fontSize=axFontSize); 
cb.TickLabelInterpreter = 'latex';
cb.FontSize = axFontSize*scale;
ax=gca; 
% ax.FontSize = axFontSize;
ax.XLabel.FontSize = labelFontSize; 
ax.YLabel.FontSize = labelFontSize;
set(gca,'TickLength',[0 0])
f.Visible = 'off';
ax.Visible = 'off';
allText = findall(gca, 'Type', 'Text');
allAxes = findall(gcf, 'Type', 'Axes');
set(allAxes, 'ticklabelinterpreter', 'latex');
set(allText(isvalid(allText)), 'interpreter', 'latex');
saveas(gcf,'colorbar', saveType)