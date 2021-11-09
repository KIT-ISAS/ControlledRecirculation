function [tpr] = epsi(xp,xn)
%EPSI Berechnet die TPR in Abhängigkeit des Gutpartikelmassenstroms xp und
%des Schlechtpartikelmassenstrom xn
p00 =       0.998;
p10 =  -0.0001558;
p01 =  -0.0005435;
p20 =   1.288e-06;
p11 =  -4.877e-06;
p02 =   2.954e-06;
% if xp+xn>800
%     c = 1/800*0.1;
%     xp_ub = 400*ones(size(xp));
%     xn_ub = 400*ones(size(xn));
%     tpr = p00 + p10*xp_ub + p01*xn_ub + p20*xp_ub.^2 + p11*xp_ub.*xn_ub + p02*xn_ub.^2-c*(xp+xn);
% else
%     tpr = p00 + p10*xp + p01*xn + p20*xp.^2 + p11*xp.*xn + p02*xn.^2;% + ...
%     %p30*m.^3 + p21*m.^2.*n + p12*m.*n.^2 + p03*n.^3;
% end
tpr = p00 + p10*xp + p01*xn + p20*xp.^2 + p11*xp.*xn + p02*xn.^2;
tpr = min(1, max(0, tpr));    
end