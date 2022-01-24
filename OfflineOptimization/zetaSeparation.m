function [tnr] = zetaSeparation(qp,qn,scale)
%zetaSorting Calculates the TNR of the separating unit depending on 
% qp = accept particles=good particles = no-targets 
% qn = reject particles=bad particles = targets
% on the conveyor belt
a00 =       0.998;
a01 =  -0.0001558;
a10 =  -0.0005435;
a02 =   1.288e-06;
a11 =  -4.877e-06;
a20 =   2.954e-06;

tnr = scale*(a00 + a01*qn + a10*qp + a02*qn.^2 + a11*qn.*qp + a20*qp.^2);
tnr = min(1, max(0, tnr));    
end