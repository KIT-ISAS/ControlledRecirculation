% For plotting qP and qN (mass flow on the first transport medium)
% Be careful: you can not simply run the script, since it plots two
% different functions. Simply run the rows you need. Creating a pdf is
% already implemented but is commented out
%% settings
scale = 4;
saveType = 'png';
axFontSize = 28;
labelFontSize = 38;

%% Plot qP
plot( qP_fitted, [uP_fit, uN_fit],qP_fit )
xlabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
ylabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
zlabel('$\overline{q}_{\mathrm{P}}$','Interpreter','Latex')
% save as pdf
%prepareFig([8,6],scaling=scale);
ax=gca; 
ax.FontSize = axFontSize;
ax.XLabel.FontSize = labelFontSize; 
ax.YLabel.FontSize = labelFontSize;
ax.ZLabel.FontSize = labelFontSize;
%saveas(gcf,'qP', saveType)

%% plot qN
plot( qN_fitted, [uP_fit, uN_fit],qN_fit )
xlabel('$\overline{u}_{\mathrm{P}}$','Interpreter','Latex')
ylabel('$\overline{u}_{\mathrm{N}}$','Interpreter','Latex')
zlabel('$\overline{q}_{\mathrm{N}}$','Interpreter','Latex')
%saveas(gcf,'qN', saveType)
ax.ZLabel.FontSize = labelFontSize;
