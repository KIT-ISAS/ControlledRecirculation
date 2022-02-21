clear all
load('C:\Users\Jonathan\Documents\UNI\13.Semester\Seminare\Messdaten\Simulationen_Sortiererkennlinie_075bar_blocked_nozzle_series2_extended\Sortiererkennlinie_fit2.mat')
% symmetrisch?
symmetrisch = 1;
% Koeffizienten des Gütemaßes J
c = [1 -1 -1 1];
% Welche Funktion soll dargestellt werden?
% Optionen: TPR, FPR, TNR, FNR, J, f1
pl = 'TNR_partikel';
% y-Axis
% percentage_P = 10:10:50;
% x-axis
% mass_total = [10:20:210 250:40:410];
%% Initialize
y_fit = 0;
x_fit = 0;
extra = [];

%% Berechnung der zum fitten benötigten Vektoren
i = 1;
j_id = 0;
percentage_P = percentage_P/100;
percentage_P_sym = [0.6 0.7 0.8 0.9];
for j=mass_total
    j_id = j_id + 1;
    k_id = 0;
    k_sym_id = 0;
    for k=percentage_P
        k_id = k_id + 1;
        % Massenstrom
        x_fit(i) = j;
        % Gutpartikelanteil
        y_fit(i) = k;
        % Genauigkeiten
        z_fit_TPR(i) = grid_y_TP(j_id,k_id)/(grid_y_TP(j_id,k_id)+grid_y_FN(j_id,k_id));
        z_fit_FPR(i) = grid_y_FP(j_id,k_id)/(grid_y_TN(j_id,k_id)+grid_y_FP(j_id,k_id));
        z_fit_FNR(i) = grid_y_FN(j_id,k_id)/(grid_y_TP(j_id,k_id)+grid_y_FN(j_id,k_id));
        z_fit_TNR(i) = grid_y_TN(j_id,k_id)/(grid_y_TN(j_id,k_id)+grid_y_FP(j_id,k_id));
        z_fit_TP(i) = grid_y_TP(j_id,k_id);
        z_fit_FP(i) = grid_y_FP(j_id,k_id);
        z_fit_FN(i) = grid_y_FN(j_id,k_id);
        z_fit_TN(i) = grid_y_TN(j_id,k_id);
        i = i+1;
    end
    if symmetrisch
        for k=percentage_P_sym
            k_sym_id = k_sym_id+1;
            % Massenstrom
            x_fit(i) = j;
            % Gutpartikelanteil
            y_fit(i) = k;
            % Genauigkeiten
            z_fit_TPR(i) = grid_y_TN(j_id,k_id-k_sym_id)/(grid_y_TN(j_id,k_id-k_sym_id)+grid_y_FP(j_id,k_id-k_sym_id));
            z_fit_FPR(i) = grid_y_FN(j_id,k_id-k_sym_id)/(grid_y_TP(j_id,k_id-k_sym_id)+grid_y_FN(j_id,k_id-k_sym_id));
            z_fit_FNR(i) = grid_y_FP(j_id,k_id-k_sym_id)/(grid_y_TN(j_id,k_id-k_sym_id)+grid_y_FP(j_id,k_id-k_sym_id));
            z_fit_TNR(i) = grid_y_TP(j_id,k_id-k_sym_id)/(grid_y_TP(j_id,k_id-k_sym_id)+grid_y_FN(j_id,k_id-k_sym_id));
            z_fit_TP(i) = grid_y_TN(j_id,k_id-k_sym_id);
            z_fit_FP(i) = grid_y_FN(j_id,k_id-k_sym_id);
            z_fit_FN(i) = grid_y_FP(j_id,k_id-k_sym_id);
            z_fit_TN(i) = grid_y_TP(j_id,k_id-k_sym_id);
            i = i+1;
        end
    end
end

% Massenfluss der Gutpartikel
p_fit = x_fit.*y_fit;
% Massenfluss der Schlechtpartikel
n_fit = x_fit - p_fit;

%% fitten der verschiedenen Funktionen
% Funktionen in Abhängigkeit von x (Massenstrom) und y (Gutpartikelanteil)
y_TP_fit = fit([x_fit', y_fit'],z_fit_TP','poly33');
y_FP_fit = fit([x_fit', y_fit'],z_fit_FP','poly33');
y_FN_fit = fit([x_fit', y_fit'],z_fit_FN','poly33');
y_TN_fit = fit([x_fit', y_fit'],z_fit_TN','poly33');
y_TPR_fit = fit([x_fit', y_fit'],z_fit_TPR','poly33');
y_FPR_fit = fit([x_fit', y_fit'],z_fit_FPR','poly33');
y_FNR_fit = fit([x_fit', y_fit'],z_fit_FNR','poly33');
y_TNR_fit = fit([x_fit', y_fit'],z_fit_TNR','poly33');
% Funktionen in Abhängigkeit von p (Target-Massenstrom) und n
% (No-Target-Massenstrom)
[tpr_fit,gofTPR] = fit([p_fit', n_fit'],z_fit_TPR','poly22');
[tnr_fit,gofTNR] = fit([p_fit', n_fit'],z_fit_TNR','poly22');

%% symbolic functions
coeff_TP = zeros(1,10);
coeff_FP = zeros(1,10);
coeff_FN = zeros(1,10);
coeff_TN = zeros(1,10);
c_TP_n = length(coeffvalues(y_TP_fit));
c_FP_n = length(coeffvalues(y_FP_fit));
c_FN_n = length(coeffvalues(y_FN_fit));
c_TN_n = length(coeffvalues(y_TN_fit));
coeff_TP(1:c_TP_n) = coeffvalues(y_TP_fit);
coeff_FP(1:c_FP_n) = coeffvalues(y_FP_fit);
coeff_FN(1:c_FN_n) = coeffvalues(y_FN_fit);
coeff_TN(1:c_TN_n) = coeffvalues(y_TN_fit);
syms x y        
y_TP_sym = coeff_TP(1) + coeff_TP(2)*x+ coeff_TP(3)*y+ coeff_TP(4)*x.^2+ coeff_TP(5)*y*x + ...
    coeff_TP(6)*y^2 +coeff_TP(7)*x^3 +coeff_TP(8)*y*x^2 + coeff_TP(9)*y^2*x +coeff_TP(10)*y^3;
y_FP_sym = coeff_FP(1) + coeff_FP(2)*x+ coeff_FP(3)*y+ coeff_FP(4)*x.^2+ coeff_FP(5)*y*x + ...
    coeff_FP(6)*y^2 +coeff_FP(7)*x^3 +coeff_FP(8)*y*x^2 + coeff_FP(9)*y^2*x +coeff_FP(10)*y^3;
y_FN_sym = coeff_FN(1) + coeff_FN(2)*x+ coeff_FN(3)*y+ coeff_FN(4)*x.^2+ coeff_FN(5)*y*x + ...
    coeff_FN(6)*y^2 +coeff_FN(7)*x^3 +coeff_FN(8)*y*x^2 + coeff_FN(9)*y^2*x +coeff_FN(10)*y^3;
y_TN_sym = coeff_TN(1) + coeff_TN(2)*x+ coeff_TN(3)*y+ coeff_TN(4)*x.^2+ coeff_TN(5)*y*x + ...
    coeff_TN(6)*y^2 +coeff_TN(7)*x^3 +coeff_TN(8)*y*x^2 + coeff_TN(9)*y^2*x +coeff_TN(10)*y^3;
coeff_TPR = zeros(1,10);
coeff_FPR = zeros(1,10);
coeff_FNR = zeros(1,10);
coeff_TNR = zeros(1,10);
c_TPR_n = length(coeffvalues(y_TP_fit));
c_FPR_n = length(coeffvalues(y_FP_fit));
c_FNR_n = length(coeffvalues(y_FN_fit));
c_TNR_n = length(coeffvalues(y_TN_fit));
coeff_TPR(1:c_TPR_n) = coeffvalues(y_TPR_fit);
coeff_FPR(1:c_FPR_n) = coeffvalues(y_FPR_fit);
coeff_FNR(1:c_FNR_n) = coeffvalues(y_FNR_fit);
coeff_TNR(1:c_TNR_n) = coeffvalues(y_TNR_fit);
y_TPR_sym = coeff_TPR(1) + coeff_TPR(2)*x+ coeff_TPR(3)*y+ coeff_TPR(4)*x.^2+ coeff_TPR(5)*y*x + ...
    coeff_TPR(6)*y^2 +coeff_TPR(7)*x^3 +coeff_TPR(8)*y*x^2 + coeff_TPR(9)*y^2*x +coeff_TPR(10)*y^3;
y_FPR_sym = coeff_FPR(1) + coeff_FPR(2)*x+ coeff_FPR(3)*y+ coeff_FPR(4)*x.^2+ coeff_FPR(5)*y*x + ...
    coeff_FPR(6)*y^2 +coeff_FPR(7)*x^3 +coeff_FPR(8)*y*x^2 + coeff_FPR(9)*y^2*x +coeff_FPR(10)*y^3;
y_FNR_sym = coeff_FNR(1) + coeff_FNR(2)*x+ coeff_FNR(3)*y+ coeff_FNR(4)*x.^2+ coeff_FNR(5)*y*x + ...
    coeff_FNR(6)*y^2 +coeff_FNR(7)*x^3 +coeff_FNR(8)*y*x^2 + coeff_FNR(9)*y^2*x +coeff_FNR(10)*y^3;
y_TNR_sym = coeff_TNR(1) + coeff_TNR(2)*x+ coeff_TNR(3)*y+ coeff_TNR(4)*x.^2+ coeff_TNR(5)*y*x + ...
    coeff_TNR(6)*y^2 +coeff_TNR(7)*x^3 +coeff_TNR(8)*y*x^2 + coeff_TNR(9)*y^2*x +coeff_TNR(10)*y^3;

%% Plotten
% for the view
caz = 134.7;
cel=15.0707;
switch pl
    case 'TP'
        plot( y_TP_fit, [x_fit', y_fit'],z_fit_TP' )
        xlabel('Mass flow in g/s')
        ylabel('Anteil "Targets" in %')
        zlabel('True Targets')
%         zlim([0 1])
    case 'FP'
        plot( y_FP_fit, [x_fit', y_fit'],z_fit_FP' )
        xlabel('Mass flow in g/s')
        ylabel('Anteil "Targets" in %')
        zlabel('False Targets')
%         zlim([0 0.3])
    case 'FN'
        plot( y_FN_fit, [x_fit', y_fit'],z_fit_FN' )
        xlabel('Mass flow in g/s')
        ylabel('Anteil "Targets" in %')
        zlabel('False "No Targets"')
        %zlim([0 0.1])
    case 'TN'
        plot( y_TN_fit, [x_fit', y_fit'],z_fit_TN' )
        xlabel('Mass flow in g/s')
        ylabel('Anteil "Targets" in %')
        zlabel('TN')
        %zlim([0 1])
    case 'TPR'
        plot( y_TPR_fit, [x_fit', y_fit'],z_fit_TPR' )
        xlabel('m in g/s')
        ylabel('a')
        zlabel('\epsilon')
        set(gcf,'color','w');
        %zlim([0.5 1])
        %xlim([0 250])
        %ylim([0.1 20])
    case 'FPR'
        plot( y_FPR_fit, [x_fit', y_fit'],z_fit_FPR' )
        xlabel('Mass flow in g/s')
        ylabel('Anteil "Targets" in %')
        zlabel('FPR')
%         zlim([0 0.3])
    case 'FNR'
        plot( y_FNR_fit, [x_fit', y_fit'],z_fit_FNR' )
        xlabel('Mass flow in g/s')
        ylabel('Anteil "Targets" in %')
        zlabel('FNR')
%         zlim([0 0.3])
    case 'TNR'
        plot( y_TNR_fit, [x_fit', y_fit'],z_fit_TNR' )
        xlabel('m in g/s')
        ylabel('a')
        zlabel('\zeta')
        set(gcf,'color','w');
%         zlim([0 1])
    case 'J'
        J = c(1)*y_TP_sym + c(2)*y_FP_sym + c(3)*y_FN_sym + c(4)*y_TN_sym;
        fsurf(J,[10 210 10 50])
        xlabel('Mass flow in g/s')
        ylabel('Anteil "Targets" in %')
        zlabel('J')
    case 'J_rate'
        J = c(1)*y_TPR_sym + c(2)*y_FPR_sym + c(3)*y_FNR_sym + c(4)*y_TNR_sym;
        fsurf(J,[10 210 10 50])
        xlabel('Mass flow in g/s')
        ylabel('Anteil "Targets" in %')
        zlabel('J')
    case 'f1'
        J = 2*y_TP_sym/(2*y_TP_sym + y_FP_sym + y_FN_sym);
        fsurf(J,[10 210 10 50])
        xlabel('Mass flow in g/s')
        ylabel('Anteil "Targets" in %')
        set(gcf,'color','w');
        zlabel('F1-score')
    case 'TNR_partikel'
        plot( tnr_fit, [p_fit', n_fit'],z_fit_TNR' )
        hxL=xlabel('$q_{\mathrm{P}}$ in $\mathrm{g}\mathrm{s}^{-1}$','Interpreter','Latex')
        hyL=ylabel('$q_{\mathrm{N}}$ in $\mathrm{g}\mathrm{s}^{-1}$','Interpreter','Latex')
        zlabel('$\zeta$','Interpreter','Latex')
        set(gcf,'color','w');
%         zlim([0.65 1])
    case 'TPR_partikel'
        plot( tpr_fit, [p_fit', n_fit'],z_fit_TPR' )
        hxL=xlabel('$q_{\mathrm{P}}$ in $\mathrm{g}\mathrm{s}^{-1}$','Interpreter','Latex')
        hyL=ylabel('$q_{\mathrm{N}}$ in $\mathrm{g}\mathrm{s}^{-1}$','Interpreter','Latex')
        zlabel('$\epsilon$','Interpreter','Latex')
        set(gcf,'color','w');
%         zlim([0.7 1])        
end
view([caz,cel]);
hyL.Position=hyL.Position+[100 -170 -0.07];
hxL.Position=hxL.Position+[-100 150 -0.04];
% hyL.Position=hyL.Position+[0 0 0];
% hxL.Position=hxL.Position+[-100 150 -0.04];
prepareFig([12,6],scaling=2);
ax=gca; 
ax.XLabel.FontSize = 25.5; 
ax.YLabel.FontSize = 25.5;
ax.ZLabel.FontSize = 25.5;
saveas(gcf,pl, 'png')
