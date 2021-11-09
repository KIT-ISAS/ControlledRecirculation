function [tnr] = ceta(xp,xn)
%CETA Funktion beschreibt die TNR (y) in Abhängigkeit des Partikelflusses der
% Gutpartikel (xp) und der Schlechtpartikel (xn)
p00 =      0.9987;
p10 =  -0.0005102;
p01 =  -0.0001224;
p20 =    2.78e-06;
p11 =  -5.177e-06;
p02 =   1.115e-06;
% if xp+xn>800
%     c = 1/800*0.1;
%     xp_ub = 400*ones(size(xp));
%     xn_ub = 400*ones(size(xn));
%     tnr = p00 + p10*xp_ub + p01*xn_ub + p20*xp_ub.^2 + p11*xp_ub.*xn_ub + p02*xn_ub.^2-c*(xp+xn);
% else
%     tnr = p00 + p10*xp + p01*xn + p20*xp.^2 + p11*xp.*xn + p02*xn.^2;% ...
%     + p30*xp.^3 + p21*xp.^2.*xn + p12*xp.*xn.^2 + p03*xn.^3;
% end
tnr = p00 + p10*xp + p01*xn + p20*xp.^2 + p11*xp.*xn + p02*xn.^2;
tnr = min(1, max(0, tnr));

end

