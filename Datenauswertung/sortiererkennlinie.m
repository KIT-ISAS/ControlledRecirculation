% show figure?
disp_figure = 0;
i_end = 1400;
% starting time for calculating mean
t_min = 1.5;
% end time for calculating mean
t_max = 5;
% sampling time
delta_t = 0.005;
folder = 'C:\Users\Jonathan\Documents\UNI\13.Semester\Seminare\Messdaten\';
messversuch = 'Simulationen_Sortiererkennlinie_Serie2\';
pos = 'Positionen\Partikelpositionen_';
sort = 'Sortierung\PartikelSortierung_';
band = 'Bandbelegung.txt';
setup = 'Sort_Kalk_';
% y-Axis
percentage_Target = 10:10:50;
n_percentage = length(percentage_Target);
% x-axis
mass_total = 10:20:410;
n_mass = length(mass_total);
grid_y_TP = zeros(n_mass,n_percentage);
grid_y_FP = zeros(n_mass,n_percentage);
grid_y_FN = zeros(n_mass,n_percentage);
grid_y_TN = zeros(n_mass,n_percentage);
grid_q_targets= zeros(n_mass,n_percentage);
grid_q_noTargets= zeros(n_mass,n_percentage);
grid_targets = zeros(n_mass,n_percentage);
grid_noTargets = zeros(n_mass,n_percentage);
j_id = 0;
for j=mass_total
    j_id = j_id+1;
    mass = sprintf('%dgs_LS_',j);
    str_mass = sprintf('%d g/s',j);
    str_mass = strcat('--------- mass flow: ', str_mass, ' ----------');
    disp(str_mass)
    k_id = 0;
    for k=percentage_Target
        y_targets = 0;
        y_noTargets = 0;
        k_id = k_id +1;
        percentage = sprintf('%d-%d',k,100-k);
        fn_pos = strcat(folder,messversuch,setup,mass,percentage,'\',pos);
        fn_sort = strcat(folder,messversuch,setup,mass,percentage,'\',sort);
        fn_band = strcat(folder,messversuch,setup,mass,percentage,'\',band);
        file_number_2 = 0;
        file_number_1 = 0;
        filename = strcat(folder,messversuch,setup,mass,percentage,'\','matlabfile.mat');
        % P;N
        q = zeros(2,i_end);
        % TP;FP;FN;TN
        y_final = zeros(4,i_end);
        q_error = zeros(1,i_end);
        y_error = zeros(1,i_end);
        % TP;FP;FN;TN
        y = zeros(4,i_end);
        % time
        t = zeros(1,i_end);
        if isfile(fn_band)
            bandbelegung=readtable(fn_band,"VariableNamingRule","preserve",'Delimiter','space','MultipleDelimsAsOne',true);
            % Careful: Because of the way the tex files are written, the column
            % names do not match the data. This row returns the PId
            n_particles = max(bandbelegung.CurrentTime);
            PId = zeros(1,n_particles);
            for i=1:height(bandbelegung)
                id = bandbelegung.CurrentTime(i);
                if PId(id) == 0
                    PId(i) = 1;
                    if bandbelegung.Pcolor(i) == 1
                        y_targets = y_targets +1;
                    else
                        y_noTargets = y_noTargets +1;
                    end
                end
            end
        else
            error_text = strcat('ERROR: ',fn_band,' does not exist');
            disp(error_text)
        end
        for i=1:i_end
            file_number_2 = file_number_2 + 50;
            if file_number_2 >= 10000
                file_number_2 = file_number_2 - 10000;
                file_number_1 = file_number_1 + 1;
            end
            first_number = sprintf( '%04d', file_number_1 );
            second_number = sprintf( '%04d', file_number_2 );
            t(i) = file_number_1 + file_number_2/10000;
            fn_pos_i = strcat(fn_pos,first_number,'.',second_number,'.txt');
            fn_sort_i = strcat(fn_sort,first_number,'.',second_number,'.txt');
            if isfile(fn_pos_i)
                data_pos=readtable(fn_pos_i,"VariableNamingRule","preserve",'Delimiter','semi');
                % collumn vector with id of particels
                id = data_pos.Var3;
                q(1,i) = sum(id==1);
                q(2,i) = sum(id==2);
            else
                q_error(i) = 1;
            end
        %     disp(q_error(i))
            if isfile(fn_sort_i)
                data_sort=readtable(fn_sort_i,"VariableNamingRule","preserve",'Delimiter','semi');
                % number of particles after separation at time step i
                y(4,i) = data_sort.("Targets ejected");
                y(3,i) = data_sort.("No targets ejected");
                y(2,i) = data_sort.("Targets not ejected");
                y(1,i) = data_sort.("No targets not ejected");
            else
                y_error(i) = 1;
            end
        end
        % starting point and end-point of mean calculation
        k_min = t_min/delta_t;
        k_max = t_max/delta_t;
        y_mean = calcParticleMean(y,k_min,k_max);
        q_mean = calcParticleMean(q,k_min,k_max);
        grid_y_TP(j_id,k_id) = y_mean(1);
        grid_y_FP(j_id,k_id) = y_mean(2);
        grid_y_FN(j_id,k_id) = y_mean(3);
        grid_y_TN(j_id,k_id) = y_mean(4);
        grid_q_targets(j_id,k_id) = q_mean(1);
        grid_q_noTargets(j_id,k_id) = q_mean(2);
        grid_targets(j_id,k_id) = y_targets;
        grid_noTargets(j_id,k_id) = y_noTargets;
        save(filename)
    end
end
filenameFull = strcat(folder,messversuch,'Sortiererkennlinie_fit2.mat');
save(filenameFull)