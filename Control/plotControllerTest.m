function plotControllerTest(T,X,mean_steps,caption,y_axis,labels)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
X = movmean(X,mean_steps,2);
X = movmean(X,mean_steps,2);
figure
p = plot(T,X','LineWidth',2);
p(3).LineStyle = '--';
p(4).LineStyle = '--';
xlabel('Zeit in s')
ylabel(y_axis)
set(gca,'FontSize',18) % Creates an axes and sets its FontSize to 18
set(gca,'fontname','times')  % Set it to times
title(caption,'Interpreter','Latex')
set(gcf,'color','w');
legend(labels,'Location','southwest')
end

