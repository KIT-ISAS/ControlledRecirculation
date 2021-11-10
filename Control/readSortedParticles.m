function y=readSortedParticles(fn)
    data=readtable(fn,"VariableNamingRule","preserve",'Delimiter','semi');
%     TN
    y(4) = data.("Targets ejected");
%     FN
    y(3) = data.("No targets ejected");
%     FP
    y(2) = data.("Targets not ejected");
%     TP
    y(1) = data.("No targets not ejected");
end