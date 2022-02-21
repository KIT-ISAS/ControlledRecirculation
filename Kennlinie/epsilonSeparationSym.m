function [tpr] = epsilonSeparationSym(qp,qn,scale)
%epsilonSeparation Calculates the TPR of the separating unit depending on 
% qp = accept particles=good particles = no-targets 
% qn = reject particles=bad particles = targets
% on the conveyor belt

a00 =      0.9995;
a10 =  -0.0005625;
a01 =  -6.69e-5;
a20 =    2.882e-06;
a11 =  -4.681e-06;
a02 =   5.773e-06;

tpr = scale*(a00 + a01*qn + a10*qp + a02*qn.^2 + a11*qn.*qp + a20*qp.^2);
end

