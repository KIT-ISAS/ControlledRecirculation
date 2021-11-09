function y=readSortedParticles(fn)
    data=readtable(fn,"VariableNamingRule","preserve",'Delimiter','semi');
    y(1) = data.("Targets ejected");
    y(2) = data.("No targets ejected");
    y(3) = data.("Targets not ejected");
    y(4) = data.("No targets not ejected");
end