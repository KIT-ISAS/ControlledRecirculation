function [opt_param,J_min] = constrainedFit(x,y,z,n_parameters)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
% ensure that x, y, z are line vectors
x = x(:)';
y = y(:)';
z = z(:)';
% Anzahl messpunkte
N = length(z);
% Zusätzliche Punkte für die constraints
[x_con,y_con] = meshgrid(max(x):200:50*max(x),max(y):200:50*max(y));
x_con = reshape(x_con,1,[]);
y_con = reshape(y_con,1,[]);
% parameters of polynom
M = length(x_con);
param0 = ones(n_parameters+N+M,1);
%% equality constraints
X = [x  x_con];
Y = [y  y_con];
% Aeq = zeros(N+M,n_parameters+N+M);

% for i=1:(N+M)
%     switch n_parameters
%         case 6
%             %Aeq = NaN(N+M, 
%             Aeq(i,1) = 1;
%             Aeq(i,2) = X(i);
%             Aeq(i,3) = X(i)^2;
%             Aeq(i,4) = Y(i);
%             Aeq(i,5) = X(i)*Y(i);
%             Aeq(i,6) =Y(i)^2;
%             Aeq(i,n_parameters+i) = -1;
%         case 10
%             Aeq(i,1) = 1;
%             Aeq(i,2) = X(i);
%             Aeq(i,3) = X(i)^2;
%             Aeq(i,4) = X(i)^3;
%             Aeq(i,5) = Y(i);
%             Aeq(i,6) = X(i)*Y(i);
%             Aeq(i,7) = X(i)^2*Y(i);
%             Aeq(i,8) = Y(i)^2;
%             Aeq(i,9) = X(i)*Y(i)^2;
%             Aeq(i,10) = Y(i)^3;
%             Aeq(i,n_parameters+i) = -1;
%     end
% end

% for i=1:(N+M)
    switch n_parameters
        case 6
            
            Aeqpart = NaN(N+M, 6);
            Aeqpart(:,1) = ones(N+M,1);
            Aeqpart(:,2) = X;
            Aeqpart(:,3) = X.^2;
            Aeqpart(:,4) = Y;
            Aeqpart(:,5) = X.*Y;
            Aeqpart(:,6) = Y.^2;
            Aeq = [Aeqpart, -eye(N+M)];
%             (i,n_parameters+i) = -1;
%         case 10
%             Aeq(i,1) = 1;
%             Aeq(i,2) = X(i);
%             Aeq(i,3) = X(i)^2;
%             Aeq(i,4) = X(i)^3;
%             Aeq(i,5) = Y(i);
%             Aeq(i,6) = X(i)*Y(i);
%             Aeq(i,7) = X(i)^2*Y(i);
%             Aeq(i,8) = Y(i)^2;
%             Aeq(i,9) = X(i)*Y(i)^2;
%             Aeq(i,10) = Y(i)^3;
%             Aeq(i,n_parameters+i) = -1;
    end
% end
beq = zeros(N+M,1);
lb = [-1*Inf(n_parameters,1);zeros(N+M,1)];
ub = [Inf(n_parameters,1);ones(N+M,1)];
Aeq = sparse(Aeq);
beq = sparse(beq);
options = optimoptions('fmincon','Algorithm','interior-point','ConstraintTolerance',...
    1e-9,'OptimalityTolerance',1e-9,'StepTolerance',1e-15,'Display','iter-detailed','MaxFunctionEvaluations',1e10);
[opt_param,J_min] = fmincon(@(param)guetemass(param,x,y,z,n_parameters,N),param0,...
    [],[],Aeq,beq,lb,ub,[],options);
i = 10;
error = opt_param(1) + opt_param(2)*x(i) + opt_param(3)*x(i)^2 ...
+opt_param(4)*y(i)+opt_param(5)*x(i)*y(i)+opt_param(6)*y(i)^2 - opt_param(i+n_parameters);
disp(error)
end
