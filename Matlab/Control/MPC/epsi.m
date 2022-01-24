function [TP_Anteil] = epsi(r_p,r_n)
%EPSI Summary of this function goes here
%   Detailed explanation goes here

delta = 0.000001;
c_N = r_n./(r_p+r_n+delta);
t2 = c_N.^2;
t3 = c_N.*1.216152772820919e-1;
t5 = c_N.*1.718305977216851e-4;
t4 = exp(t3);
t6 = -t5;
t7 = exp(t6);
t8 = t4.*3.965528248105649e+15;
t9 = t7.*2.950835993543266e+20;
t10 = -t9;
TP_Anteil = ((t8+t10).*(c_N.*2.712794053385412e+19+t2.*1.147738374932383e+17-3.299572958664278e+21).*1.965116437629977e-18)./((c_N.*(1.45e+2./2.0)-7.25e+3).*(c_N.*-7.812438090851985e+17+t2.*9.181906999459062e+15+t8+t10+3.118206848621062e+19));
TP_Anteil = min(0.999,TP_Anteil);
end

