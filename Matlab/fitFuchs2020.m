clear all
%% Parameter
% Anzahl Teilchen
n = 7250; 
% Anteil Schlechtpartikel für das function fitting:
x_cN = [10 20 30 40 48];
y_PPV = [0.998 0.996 0.9945 0.991 0.987];
y_NPV = [0.918 0.9345 0.945 0.952 0.949];

%% Die PPV und NPV Funktionen aus Fuch2020 werden gefitted
% PPV ist eine Exponentielle Funktion
PPV_fit=fit(x_cN',y_PPV','exp2')
% Für c_N < 0.5 ist NPV eine quadratische Funktion
NPV_fit=fit(x_cN',y_NPV','poly2')
% Plotten der beiden fittings
figure;
subplot(3,2,1)
plot(PPV_fit,x_cN',y_PPV')
title('Genauigkeit der Gut-Fraktion')
xlabel('c_N in %')
ylabel('PPV')
subplot(3,2,2)
plot(NPV_fit,x_cN',y_NPV')
title('Genauigkeit der Schlecht-Fraktion')
xlabel('c_N in %')
ylabel('NPV')

%% Berechnung der Fehler 
syms TP TN FP FN c_N real;
assume(c_N>10);
% Lösen des Gleichungssystems (ACHTUNG: SOll die Funktion für NPV angepasst
% werden, dann muss auch hier die Funktion geaendert werden
F(1) = TP/(TP+FP) - feval(PPV_fit,c_N);
F(2) = TN/(TN+FN) - NPV_fit.p1*c_N^2 - NPV_fit.p2*c_N - NPV_fit.p3;
F(3) = FP + TN - n*c_N/100;
F(4) = TP + FN - n + n*c_N/100;
[TP_sol,TN_sol, FP_sol, FN_sol] = solve(F==0,[TP,TN,FP,FN]);
% Interessant sind insbesondere der TP-Anteil an den Gutpartikeln und der
% TN Anteil an den Schlechtpartikeln
n_P = n - n*c_N/100;
n_N = n*c_N/100;
TP_Anteil = TP_sol/n_P;
TN_Anteil = TN_sol/n_N;
FP_Anteil = FP_sol/n_N;
FN_Anteil = FN_sol/n_P;
subplot(3,2,3)
fplot(TP_Anteil)
title('Anteil TP an den Gutpartikeln')
xlabel('c_N in %')
ylabel('TP-Anteil')
axis([10 50 0.94 1])
subplot(3,2,4)
fplot(TN_Anteil)
title('Anteil TP an den Schlechtpartikeln')
xlabel('c_N in %')
ylabel('TP-Anteil')
axis([10 50 0.96 1])
subplot(3,2,5)
fplot(FN_Anteil)
title('Anteil FN an den Gutpartikeln')
xlabel('c_N in %')
ylabel('TP-Anteil')
axis([10 50 0 0.06])
subplot(3,2,6)
fplot(FP_Anteil)
title('Anteil FP an den Schlechtpartikeln')
xlabel('c_N in %')
ylabel('TP-Anteil')
axis([10 50 0.01 0.02])
%% Berechnung der Gesamtgenauigkeit (ACC) zur Überprüfung der Ergebnisse
ACC = (TP_sol + TN_sol)/n;

%% TP_Anteil und TN_Anteil als Simulink Bock definieren
% muss nur ausgeführt werden, wenn Daten geändert werden
% matlabFunctionBlock('library_schuettgut/anteil_TP', TP_Anteil)
% matlabFunctionBlock('library_schuettgut/anteil_TN', TN_Anteil)
