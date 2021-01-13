eps_gemessen = [0.8 0.8 0.8 0.8 0.82 0.84 0.86 0.88 0.87 0.86 0.84 0.81 0.77 0.72 0.66 0.61 0.55 0.47 0.35 0.2];
x = [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20];
epsilon1 = fit(x',eps_gemessen','poly2');
% epsilon2 = -x2+1;
% epsilon = epsilon1(x1+x2) + epsilon2;

x_1 = 1:20;
x_2 = 1:20;
tp = zeros(20,20);
for i=1:20
    for j=1:20
        tp(i,j) = epsilon_test(x_1(i),x_2(j));
    end
end

tn = zeros(20,20);
for i=1:20
    for j=1:20
        tn(i,j) = zeta_test(x_1(i),x_2(j));
    end
end

surf(tn)
% surf(tp)

true = tp + tn;
[p_best, n_best] = find(true == max(max(true)))
