t_end = 20;
deltaT = 0.005;
pause(3)
for t=deltaT:deltaT:t_end
    pause(1)
    fileID = fopen('Partikelpositionen_blockiert.txt','w');
    fprintf(fileID,'%1.4f',t);
    fclose(fileID);
end