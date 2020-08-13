function [] = param_avg_to_csv(filename, Cont, Thresh, Hybrid)
%PARAM_TO_CSV Output a CSV file from .MAT structure that has the parameter
%estimates for the continuous, threshold and hybrid models in a way that is
%easy to compare across participant and models
%% Open the file
fp = fopen(filename, 'w');

%% Print the header line in the CSV.
header_line = 'model_name, v1, v2, eta, a, pi1, pi2, Ter, st, sa';
fprintf(fp, [header_line '\n']);
%% Get parameter averages across participants for each model

%Continuous
n_param = length(Cont{1,4});
params = cat(1,Cont(:,4));
params = cell2mat(params);

for i = (1:n_param)
    contAvg(1,i) = mean(params(:,i));
end

%Threshold
n_param = length(Thresh{1,4});
params = cat(1,Thresh(:,4));
params = cell2mat(params);

for i = (1:n_param)
    threshAvg(1,i) = mean(params(:,i));
end

%Hybrid
n_param = length(Hybrid{1,4});
params = cat(1,Hybrid(:,4));
params = cell2mat(params);

for i = (1:n_param)
    hybridAvg(1,i) = mean(params(:,i));
end
%% Write parameter
this_cont = contAvg;


this_line = {'Cont',...
    num2str(this_cont(1)), num2str(0),...
    num2str(this_cont(2)),num2str(this_cont(3)),...
    num2str(0),num2str(0),...
    num2str(this_cont(4)), num2str(this_cont(5)),...
    num2str(0)};
this_line = strjoin(this_line, ', ');
fprintf(fp, [this_line '\n']);

% Threshold
this_thresh = threshAvg;

this_line = {'Thresh',...
    num2str(this_thresh(1)), num2str(0),...
    num2str(0),num2str(this_thresh(2)),...
    num2str(this_thresh(3)),num2str(this_thresh(4)),...
    num2str(this_thresh(5)),num2str(this_thresh(6)),...
    num2str(0)};
this_line = strjoin(this_line, ', ');
fprintf(fp, [this_line '\n']);

% Hybrid
this_hybrid = hybridAvg;

this_line = {'Hybrid',...
    num2str(this_hybrid(1)), num2str(0),...
    num2str(this_hybrid(2)), num2str(this_hybrid(3)),...
    num2str(this_hybrid(4)), num2str(this_hybrid(5)),...
    num2str(this_hybrid(6)), num2str(this_hybrid(7)),...
    num2str(0)};
this_line = strjoin(this_line, ', ');
fprintf(fp, [this_line '\n']);

%% Close the file
fclose(fp);

end


