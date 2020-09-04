function [] = param_to_csv_avg_compare(filename, original, mix, mixdrift)
%PARAM_TO_CSV Output a CSV file from .MAT structure that has the parameter
%estimates for the continuous, threshold and hybrid models in a way that is
%easy to compare across participant and models
%% Open the file
fp = fopen(filename, 'w');

%% Print the header line in the CSV.
header_line = 'model_name, v1a, v2a, v1b, v2b, eta, a1, a2, pi1, pi2, Ter, st, sa';
fprintf(fp, [header_line '\n']);
%% Get parameter averages across participants for each model

%Continuous
n_param = length(original{1,4});
params = cat(1,original(:,4));
params = cell2mat(params);

for i = (1:n_param)
    contAvg(1,i) = mean(params(:,i));
end

%Threshold
n_param = length(mix{1,4});
params = cat(1,mix(:,4));
params = cell2mat(params);

for i = (1:n_param)
    threshAvg(1,i) = mean(params(:,i));
end

%Hybrid
n_param = length(mixdrift{1,4});
params = cat(1,mixdrift(:,4));
params = cell2mat(params);

for i = (1:n_param)
    hybridAvg(1,i) = mean(params(:,i));
end
%% Write parameter
this_og = contAvg;

this_line = {'OG',...
    num2str(this_og(1)), num2str(0),...
    num2str(this_og(1)), num2str(0),...
    num2str(0), num2str(this_og(2)),...
    num2str(this_og(3)), num2str(this_og(4)),...
    num2str(0), num2str(this_og(5)),...
    num2str(this_og(6)),num2str(0)};
this_line = strjoin(this_line, ', ');

fprintf(fp, [this_line '\n']);

% Threshold
this_mix = threshAvg;
this_line = {'MIX',...
    num2str(this_mix(1)), num2str(0),...
    num2str(this_mix(1)), num2str(0),...
    num2str(0),num2str(this_mix(2)),...
    num2str(this_mix(3)),num2str(this_mix(4)),...
    num2str(this_mix(5)),num2str(this_mix(6)),...
    num2str(this_mix(7)),num2str(0)};
this_line = strjoin(this_line, ', ');
fprintf(fp, [this_line '\n']);

% Hybrid
this_mixdrift = hybridAvg;

this_line = {'MIX_DRIFT',...
    num2str(this_mixdrift(1)), num2str(0),...
    num2str(this_mixdrift(2)), num2str(0),...
    num2str(0), num2str(this_mixdrift(3)),...
    num2str(this_mixdrift(4)), num2str(this_mixdrift(5)),...
    num2str(this_mixdrift(6)), num2str(this_mixdrift(7)),...
    num2str(this_mixdrift(8)),num2str(0)};
this_line = strjoin(this_line, ', ');
fprintf(fp, [this_line '\n']);

%% Close the file
fclose(fp);

end


