function [percentageAccept,percentageReject] = control(c)
%CONTROL Summary of this function goes here
%   Detailed explanation goes here

%% Important
% in all matrices and vectors representing mass flows or particle flows the
% accept particles are in the first row and the reject particles are in the
% second row (e.g. vectors r_measured, q

% in some other vectors it might be vice versa due to the fact that the
% acceptID is chosen as 2. This includes the vectors density, radius, 

% matrices with first dimension equal to 4 often represent mass flows after
% the separation. The order of the rows is following
% [correctly sorted accept; falsely sorted reject; falsely sorted accept; falsely sorted reject]
% [TP; FP; FN; TN] if accept are positive particles and reject are negative

%% Parameters
acceptID = 2;
rejectID = 1;
midpointMatrix = zeros(2,0,0);
orientationMatrix = zeros(0,0);
visualClassificationMatrix = zeros(0,0,0);
allParam = getDefaultParam();
allParam.live.enabled=1;
c.type='MPC';
ii=3; % Count variable for folder content 
jj = 1; % Count variable for reading particle input of system
fileID = fopen('control.txt','w');
%     fprintf(fileID,'%6s %12s %12s\n','timestep','percentageAccept','percentageReject');
%     fprintf(fileID,'%6f %12.2f %12.2f\n',[timestep percentageAccept percentageReject]);
fprintf(fileID,'%20s %20s\n','percentageAccept','percentageReject');
fprintf(fileID,'%20.2f %20.2f\n',[0.0 0.0]);
fclose(fileID);

if ~allParam.live.enabled
    startAt=max(allParam.general.startFrameNo,firstRelevantFrame);
    endAt=min(allParam.general.endFrameNo,size(numberOfMidpoints,1));
else
    startAt=1;
    % We do not want it to stop. Use double to prevent index from becoming
    % int, which can cause problems.
    endAt=double(intmax);
end

assert(startAt<endAt,'Last frame before first relevant frame. This is either an error in the config or no particles appear until endFrame.');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Initialisierung des MPC
% Massenstrom der Targets und der Massenstrom der No-Targets hin
szenarioFolder = 'Szenario';
type = [acceptID;rejectID];
% input mass flow in g/s, radius and density
[r_measured,radius,density] = getSzenario(szenarioFolder,c.fileName,c.T,type);
% Praediktionshorizont
n_p = size(r_measured,2);
% number of states
n_x = 4;
% Maximum number of particles on the conveyor belt
if isfield(c,'qMax')
    qMax = c.qMax;
else
    qMax = Inf;
end


percentageAccept = 0;
percentageReject = 0;
u = [percentageAccept;percentageReject];

% Use PI as well when using MPC?

k_hat = int16((c.tau_LV + c.tau_KO + c.tau_OL+ c.tau_V+ c.tau_SK)/c.T);
% Steuerhorizont
if isfield(c,'n_n')
    n_n = c.n_n;
else
    n_n = k_hat;
    warning('No control horizon specified: k_hat=%d is the new control horizon',k_hat)
end
x0 = zeros(4*n_n,1);
%Fuer das Einlesen der Datei, die die zweite Kamera simuliert
% Sortierte_Partikel/Partikel_xxx.txt, mit xxx = Zeitstempel
y_fol='..\Sortierte_Partikel';
y_file = 'Partikel_';

% Initialisierung der Totzeiten und Messvektoren
k_LV        = int16(c.tau_LV/c.T);
k_V         = int16(c.tau_V/c.T);
k_LK        = int16((c.tau_LV + c.tau_V + c.tau_SK)/c.T);
y_measured  = zeros(4,k_LK);
k_KL        = int16((c.tau_KO + c.tau_OL)/c.T);
q_measured  = zeros(2,k_KL);
k_VK        = int16((c.tau_V + c.tau_SK)/c.T);
u_measured  = zeros(2,k_VK);

% Initialisierung des PI des MPC
x_control = zeros(2,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for t=startAt:endAt
    % Set new mesurements
    if ~allParam.live.enabled
        % If not live, take from matrix
        currNumberOfMeasurements=numberOfMidpoints(t);
        currMeasurements=struct('midpoints',midpointMatrix(:,1:currNumberOfMeasurements,t));
        if ~isempty(orientationMatrix)
            currMeasurements.orientations=orientationMatrix(1:currNumberOfMeasurements,t);
        end
        if ~isempty(visualClassificationMatrix) % Visual classification can be given as a noFeatures x measurements x time matrix
            currMeasurements.visualClassifications=visualClassificationMatrix(:,1:currNumberOfMeasurements,t);
        end
        % Print out status
        if mod(t,50)==0
            dispstat(sprintf('At time step %d of %d',t,endAt));
        end
    else
        terminate=waitForNextTimeStep(t,allParam.live);
        if terminate
            disp('Ending live mode.');
            return
        end
        fprintf('Processing time step %d\n',t);
        % currNumberOfMeasurements = number of particles in camera area?
        [currMeasurements,currNumberOfMeasurements]=readMidpointsLive(allParam.live.DEMOutput);
        if currNumberOfMeasurements==0 % Throw warning to be able to detect when this occurred
            warning('LiveMode:NoMeas','No measurements were obtained at time step %5.5G.',t*allParam.live.timeStepMultiplier);
        end
    end
    if ~isempty(currMeasurements.visualClassifications) 
        color = currMeasurements.visualClassifications(1,:);
        % Stimmt das hier so mit den Werten 1 und 2?
        % Das hier sollen die no-targets sein
        sum_color_accept = sum(color == acceptID);
        % das hier sollen die targets sein
        sum_color_reject = sum(color == rejectID);
        switch c.type
            case 'PI'
                % Hier kommt der PI Regler hin
                percentageAccept = 0;
                percentageReject = 0;
            case 'q-P'
                % control law of proportional controller using only the conveyer camera
                percentageAccept = c.qP.a*sum_color_accept + c.qP.b*sum_color_reject;
                percentageReject = c.qP.c*sum_color_accept + c.qP.d*sum_color_reject;        
            case 'MPC'
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                q = [sum_color_accept; sum_color_reject];
                % Second Camera
                contyfol=dir(y_fol);
                if (size(contyfol,1)==ii) % Nur reingehen wenn neue Messung hinzukommt 
                        file_number_1 = contyfol(ii).name(20:23);
                        file_number_2 = contyfol(ii).name(25:28);
                    first_number=file_number_1;
                    second_number=file_number_2;                   
                    y_fileStamp = strcat(y_fol,'\',y_file,first_number,'.',second_number,'.txt');
                    y = readSortedParticles(y_fileStamp);
                    % q and y are measured in particles/s, since they are
                    % simply counted. The characteristics of the separation
                    % unit and the vector r are using the unit g/s
                    % Therefore, the units of y and q have to be transformed
                    % to g/s
                    y_type = [acceptID;rejectID;acceptID;rejectID];
                    q_type = [acceptID;rejectID];
                    y = particles2grams(y,y_type,density, radius);
                    q = particles2grams(q,q_type,density, radius);
                    % Messvektoren werden mit 0en initialisiert und dann wird in jedem
                    % Zeitschritt der aellteste Wert geloescht und der aktuellste neu
                    % eingefuegt
                    y_measured(:,1)     = [];
                    y_measured(:,k_LK)  = y;
                    u_measured(:,1)     = [];
                    u_measured(:,k_VK)  = u;
                    q_measured(:,1)     = [];
                    q_measured(:,k_KL)  = q;
                    if n_p > 1
                        % Zufluss wird nicht als konstant angenommen
                        r = r_measured(:,jj:n_p);
                    else
                        % Zufluss wird als konstant angenommen
                        r = r_measured;
                    end
                    [uMPC,x_opt,exitflag,fval] = ...
                        mpcSchuettgut(r, x0, y_measured, q_measured, u_measured,n_n, ...
                        k_hat,k_LV,k_V,k_VK,k_KL,n_x, [c.weights.cTPR 0 0 c.weights.cTNR], c.objective, [0 0],1,qMax);
                    x0 = x_opt; 
                    ii=ii+1;
                    jj = jj +1;
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            case 'stochastic'
                % Hier kommt der stochastische Regler hin
                percentageAccept = 0.5;
                percentageReject = 0.5;
            otherwise
                warning('unknown controller type.')
        end
    end
    switch c.type
        case 'MPC'
        % time discrete PI controller as described in [Lunze2020
        % Regelungstechnik 2 p. 524]
        x_control = x_control + uMPC - u;
        u = -kI*x_control -kP*(uMPC-u);
    end
    fprintf('Accept percentage %f\n',percentageAccept);
    fprintf('Reject percentage %f\n',percentageReject);
    % Print to file
    fileID = fopen('control.txt','w');
%     fprintf(fileID,'%6s %12s %12s\n','timestep','percentageAccept','percentageReject');
%     fprintf(fileID,'%6f %12.2f %12.2f\n',[timestep percentageAccept percentageReject]);
    fprintf(fileID,'%20s %20s\n','percentageAccept','percentageReject');
    fprintf(fileID,'%20.5f %20.5f\n',[percentageAccept percentageReject]);
    fclose(fileID);
end
end

