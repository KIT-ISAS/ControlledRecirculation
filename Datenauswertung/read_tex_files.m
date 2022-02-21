% save or load data
save_file = 0;
% show figure?
disp_figure = 1;
i_end = 12000;
t_end = 12000;
if save_file==1
    folder = 'C:\Users\Jonathan\Documents\UNI\13.Semester\Seminare\Messdaten\';
    messversuch = 'Simulationen_Sortiererkennlinie\';
    setup = 'Setup_Recirculation_NoTarget_100gs_50-50\';
    pos = 'Positionen\Partikelpositionen_';
    sort = 'Sortierung\PartikelSortierung_';
    fn_pos = strcat(folder,messversuch,setup,pos);
    fn_sort = strcat(folder,messversuch,setup,sort);
    file_number_2 = 0;
    file_number_1 = 0;
    filename = strcat(folder,messversuch,setup,'matlabfile.mat');
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
    %     disp(fn_pos_i)
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
            % number of particles in the boxes after time step i
            y_final(1,i) = data_sort.("Gut in Gut");
            y_final(2,i) = data_sort.("Schlecht in Gut");
            y_final(3,i) = data_sort.("Gut in Schlecht");
            y_final(4,i) = data_sort.("Schlecht in Schlecht");
            % in time step i new added particles
            y(:,i) = y_final(:,i)-y_final(:,i-1);
        else
            y_error(i) = 1;
        end
    end
    save(filename)
end
if disp_figure
    % moving average filter used for smooting
    % span: Number of data points for calculating the smoothed value
    % time distance between two measurments: 5 ms
    % span = 50 => time distance is 0.25 s
    smoothing = 0;
    if smoothing
        span = 100;
        subplot(2,1,1)
        plot(t(1:t_end)',[smooth(q(1,1:t_end)',span),smooth(q(2,1:t_end)',span)]);
        xlabel('Zeit in s')
        ylabel('Partikel auf dem Fließband q')
        legend('q_P','q_N','Location','southeast');

        subplot(2,1,2)
        plot(t(1:t_end)',[smooth(y(1,1:t_end)',span),smooth(y(2,1:t_end)',span),smooth(y(3,1:t_end)',span),smooth(y(4,1:t_end)',span)])
        ylabel('Partikel nach der Sortierung y')
        legend('y_{TP}','y_{FP}','y_{FN}','y_{TN}','Location','northwest');
        xlabel('Zeit in s')
        %ylim([0 1.8])
    else
        span = 1;
        subplot(3,1,1)
        plot(t(1:t_end)',[smooth(q(1,1:t_end)',span),smooth(q(2,1:t_end)',span)]);
        xlabel('Zeit in s')
        ylabel('Partikel auf dem Fließband q')
        legend('q_P','q_N','Location','northwest');

        subplot(3,1,2)
        plot(t(1:t_end)',[smooth(y(1,1:t_end)',span),smooth(y(2,1:t_end)',span),smooth(y(3,1:t_end)',span),smooth(y(4,1:t_end)',span)])
        ylabel('Partikel nach der Sortierung y')
        legend('y_{TP}','y_{FP}','y_{FN}','y_{TN}','Location','northwest');
        xlabel('Zeit in s')

        subplot(3,1,3)
        plot(t(1:t_end)',y_final(:,1:t_end)')
        ylabel('Partikel in den Boxen Y')
        legend('Y_{TP}','Y_{FP}','Y_{FN}','Y_{TN}','Location','northwest');
        xlabel('Zeit in s')
    end
end