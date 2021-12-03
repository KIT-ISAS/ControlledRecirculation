acceptID = 2;
rejectID = 1;
q_type = [acceptID;rejectID];
% density in kg/m^3
density = [2565;2541];
% radius in mm
radius = [3;3];
t_end = 27;
deltaT = 0.005;
folder = 'Sortierung\Sort_Kalk_10gs_LS_50-50';
folderSort = 'Sortierung';
folderPos = 'Positionen';
filePos = 'Partikelpositionen_';
fileSort = 'PartikelSortierung_';
file_number_1 = 0;
file_number_2 = 0;
list_ID = [];
particles = [];
ii = 1;
timesteps_measured = 0;
Q = zeros(2,t_end/deltaT);
for t=deltaT:deltaT:t_end
    file_number_2 = int16(10000*(t-floor(t)));
    file_number_1 = floor(t);
    first_number = sprintf( '%04d', file_number_1 );
    second_number = sprintf( '%04d', file_number_2 );
    fileP = strcat(filePos,first_number,'.',second_number,'.txt');
    fn_pos = strcat(folder,'\',folderPos,'\',fileP);
    if isfile(fn_pos)
        fileID = fopen(fn_pos,'r');
        string = fscanf(fileID,'%c');
        fclose(fileID);
        fileID = fopen('Partikelpositionen.txt','w');
        fprintf(fileID,'X-Position;Y-Position;PColor;PID\n');
        fprintf(fileID,string);
        fclose(fileID);
        [currMeasurements,currNumberOfMeasurements]=readMidpointsLive('Partikelpositionen.txt');
        color = currMeasurements.visualClassifications(1,:);
        ID = currMeasurements.visualClassifications(2,:);
        members = ismember(ID,list_ID);
        % list_ID is a matrix containing the IDs of all already detected
        % particles
        list_ID = [list_ID ID(~members)];
        particles = [particles color(~members)];
        % Das hier sollen die no-targets sein
        sum_color_accept = sum(particles == acceptID);
        % das hier sollen die targets sein
        sum_color_reject = sum(particles == rejectID);
        Q(:,ii) = [sum_color_accept; sum_color_reject];
        timesteps_measured = timesteps_measured + 1;
    else
        Q(:,ii) = [-1; -1];
    end
    ii = ii+1;
end
q_total = max(Q,[],2);
T_total = timesteps_measured*deltaT;
q_ps = q_total/T_total;
% q is measured in particles/s, since they are
% simply counted. The characteristics of the separation
% unit and the vector r are using the unit g/s
% Therefore, the unit of q have to be transformed
% to g/s
q_gs = particles2grams(q_ps,q_type,density, radius);