function [tpr] = epsilonSeparation(qp,qn,scale)
%epsilonSeparation Calculates the TPR of the separating unit depending on 
% qp = accept particles=good particles = no-targets 
% qn = reject particles=bad particles = targets
% on the conveyor belt

a00 =      0.9987;
a01 =  -0.0005102;
a10 =  -0.0001224;
a02 =    2.78e-06;
a11 =  -5.177e-06;
a20 =   1.115e-06;

tpr = scale*(a00 + a01*qn + a10*qp + a02*qn.^2 + a11*qn.*qp + a20*qp.^2);
tpr = min(1, max(0, tpr));

end

