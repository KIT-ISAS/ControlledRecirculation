function y=readSortedParticles(fn)
%     data=readtable(fn,"VariableNamingRule","preserve",'Delimiter','semi');
    data=importdata(fn);
    if ~iscell(data) % Falls nur Header drin steht 
        y(4) = sum(data.data(:,1)==1); % target rejected
    %     FN
        y(3) = sum(data.data(:,1)==2); % notarget rejected
    %     FP
        y(2) = sum(data.data(:,1)==3); % target accepted
    %     TP
        y(1) = sum(data.data(:,1)==4); % notarget accepted
    else
        y(1:4)=0;
    end
end