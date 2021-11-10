function y=readSortedParticles(fn)
    data=readtable(fn,"VariableNamingRule","preserve",'Delimiter','semi');
%     TN
    y(4) = data.("1"); % target rejected
%     FN
    y(3) = data.("2"); % notarget rejected
%     FP
    y(2) = data.("3"); % target accepted
%     TP
    y(1) = data.("4"); % notarget accepted
end