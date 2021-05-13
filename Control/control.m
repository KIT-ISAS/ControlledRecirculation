function [percentageAccept,percentageReject] = control(controller)
%CONTROL Summary of this function goes here
%   Detailed explanation goes here

%% Parameters
midpointMatrix = zeros(2,0,0);
orientationMatrix = zeros(0,0);
visualClassificationMatrix = zeros(0,0,0);
allParam = getDefaultParam();

% if ~allParam.live.enabled
%     startAt=max(generalParam.startFrameNo,firstRelevantFrame);
%     endAt=min(generalParam.endFrameNo,size(numberOfMidpoints,1));
% else
%     startAt=1;
%     % We do not want it to stop. Use double to prevent index from becoming
%     % int, which can cause problems.
%     endAt=double(intmax);
% end

startAt=1;
% We do not want it to stop. Use double to prevent index from becoming
% int, which can cause problems.
endAt=double(intmax);

assert(startAt<endAt,'Last frame before first relevant frame. This is either an error in the config or no particles appear until endFrame.');

for t=startAt:endAt
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
    color = currMeasurements.visualClassifications(1,:);
    % Stimmt das hier so mit den Werten 1 und 2?
    sum_color_accept = sum(color == 2);
    sum_color_reject = sum(color == 1);
    switch controller.type
        case 'PI'
            % Hier kommt der PI Regler hin
            percentageAccept = 0;
            percentageReject = 0;
        case 'q-P'
            % control law of proportional controller using only conveyer camera
            percentageAccept = controller.qP.a*sum_color_accept + controller.qP.b*sum_color_reject;
            percentageReject = controller.qP.c*sum_color_accept + controller.qP.d*sum_color_reject;        
        case 'MPC'
            % Hier würde ein MPC hinkommen
            percentageAccept = 0;
            percentageReject = 0;
        case 'stochastic'
            % Hier kommt der stochastische Regler hin
            percentageAccept = 0;
            percentageReject = 0;
        otherwise
            warning('unknown controller type.')
    end
    percentageAccept = min(max(percentageAccept, 0),1);
    percentageReject = min(max(percentageReject, 0),1);
    % Print to file
    fileID = fopen('control.txt','w');
%     fprintf(fileID,'%6s %12s %12s\n','timestep','percentageAccept','percentageReject');
%     fprintf(fileID,'%6f %12.2f %12.2f\n',[timestep percentageAccept percentageReject]);
    fprintf(fileID,'%20s %20s\n','percentageAccept','percentageReject');
    fprintf(fileID,'%20.2f %20.2f\n',[percentageAccept percentageReject]);
    fclose(fileID);
end

% for t=startAt:endAt
%     % Set new mesurements
%     if ~allParam.live.enabled
%         % If not live, take from matrix
%         currNumberOfMeasurements=numberOfMidpoints(t);
%         currMeasurements=struct('midpoints',midpointMatrix(:,1:currNumberOfMeasurements,t));
%         if ~isempty(orientationMatrix)
%             currMeasurements.orientations=orientationMatrix(1:currNumberOfMeasurements,t);
%         end
%         if ~isempty(visualClassificationMatrix) % Visual classification can be given as a noFeatures x measurements x time matrix
%             currMeasurements.visualClassifications=visualClassificationMatrix(:,1:currNumberOfMeasurements,t);
%         end
%         % Print out status
%         if mod(t,50)==0
%             dispstat(sprintf('At time step %d of %d',t,endAt));
%         end
%     else
%         terminate=waitForNextTimeStep(t,allParam.live);
%         if terminate
%             disp('Ending live mode.');
%             return
%         end
%         fprintf('Processing time step %d\n',t);
%         % currNumberOfMeasurements = number of particles in camera area?
%         [currMeasurements,currNumberOfMeasurements]=readMidpointsLive(allParam.live.DEMOutput);
%         if currNumberOfMeasurements==0 % Throw warning to be able to detect when this occurred
%             warning('LiveMode:NoMeas','No measurements were obtained at time step %5.5G.',t*allParam.live.timeStepMultiplier);
%         end
%     end
%     color = currMeasurements.visualClassifications(1,:);
%     % Stimmt das hier so mit den Werten 1 und 2?
%     sum_color_accept = sum(color == 2);
%     sum_color_reject = sum(color == 1);
%     switch controller.type
%         case 'PI'
%             % Hier kommt der PI Regler hin
%             percentageAccept = 0;
%             percentageReject = 0;
%         case 'q-P'
%             % control law of proportional controller using only conveyer camera
%             percentageAccept = controller.qP.a*sum_color_accept + controller.qP.b*sum_color_reject;
%             percentageReject = controller.qP.c*sum_color_accept + controller.qP.d*sum_color_reject;        
%         case 'MPC'
%             % Hier würde ein MPC hinkommen
%             percentageAccept = 0;
%             percentageReject = 0;
%         case 'stochastic'
%             % Hier kommt der stochastische Regler hin
%             percentageAccept = 0;
%             percentageReject = 0;
%         otherwise
%             warning('unknown controller type.')
%     end
%     percentageAccept = min(max(percentageAccept, 0),1);
%     percentageReject = min(max(percentageReject, 0),1);
%     % Print to file
%     fileID = fopen('control.txt','w');
% %     fprintf(fileID,'%6s %12s %12s\n','timestep','percentageAccept','percentageReject');
% %     fprintf(fileID,'%6f %12.2f %12.2f\n',[timestep percentageAccept percentageReject]);
%     fprintf(fileID,'%20s %20s\n','percentageAccept','percentageReject');
%     fprintf(fileID,'%20.2f %20.2f\n',[percentageAccept percentageReject]);
%     fclose(fileID);
% end
end

