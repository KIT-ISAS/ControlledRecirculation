function [TN_Anteil] = ceta(r_p,r_n)
%CETA Summary of this function goes here
%   Detailed explanation goes here

delta = 0.000001;
c_N = r_n./(r_p+r_n+delta);
t2 = c_N.^2;
t3 = c_N.*1.216152772820919e-1;
t5 = c_N.*1.718305977216851e-4;
t4 = exp(t3);
t6 = -t5;
t7 = exp(t6);
TN_Anteil = ((c_N.*3.906219045425992e+17-t2.*4.590953499729531e+15+1.319829183465711e+20).*(c_N.*7.378697629483821e+19-t4.*9.913820620264122e+16+t7.*7.377089983858165e+21-7.378697629483821e+21).*(-2.710505431213761e-20))./(c_N.*(c_N.*-7.812438090851985e+17+t2.*9.181906999459062e+15+t4.*3.965528248105649e+15-t7.*2.950835993543266e+20+3.118206848621062e+19));
TN_Anteil = min(0.999,TN_Anteil);
TN_Anteil = max(0,TN_Anteil);
end

