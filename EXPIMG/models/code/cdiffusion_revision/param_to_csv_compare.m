function [] = param_to_csv_compare(filename, participants, original, mixing, mixdrift)
%PARAM_TO_CSV Output a CSV file from .MAT structure that has the parameter
%estimates for the continuous, threshold and hybrid models in a way that is
%easy to compare across participant and models
  %% Open the file
  fp = fopen(filename, 'w');

%% Print the header line in the CSV.
header_line = 'participant, model_name, BIC, v1a, v2a, v1b, v2b, eta, a1, a2, pi1, pi2, Ter, st, sa';
fprintf(fp, [header_line '\n']);


%% Write parameter

for i = participants
    
    %% There appears to be a strange observer without any data in them, so
% %      let's skip over anyone who doesn't seem to have data.
    if isempty(original{i,1})
        continue
    end
    
    %% Get the appropriate model parameters
    %troubleshooting
    disp('Participant')
    disp(i);
    
    % Original Model
    this_og = original{i,4};
    
    this_line = { num2str(i), 'OG',num2str(original{i,2}),...
        num2str(this_og(1)), num2str(0),...
        num2str(this_og(1)), num2str(0),...
        num2str(0), num2str(this_og(2)),...
        num2str(this_og(3)), num2str(this_og(4)),...
        num2str(0), num2str(this_og(5)),...
        num2str(this_og(6)),num2str(0)};
    this_line = strjoin(this_line, ', ');
    fprintf(fp, [this_line '\n']);
    
    % Mixing Proportions
    this_mix = mixing{i,4};
    
    this_line = { num2str(i), 'MIX',num2str(mixing{i,2}),...
        num2str(this_mix(1)), num2str(0),...
        num2str(this_mix(1)), num2str(0),...
        num2str(0),num2str(this_mix(2)),...
        num2str(this_mix(3)),num2str(this_mix(4)),...
        num2str(this_mix(5)),num2str(this_mix(6)),...
        num2str(this_mix(7)),num2str(0)};
    this_line = strjoin(this_line, ', ');
    fprintf(fp, [this_line '\n']);
    
    % Mixing Proportions and Mean Drift 
    this_mixdrift = mixdrift{i,4};
    
    this_line = { num2str(i), 'MIX_DRIFT', num2str(mixdrift{i,2}),...
        num2str(this_mixdrift(1)), num2str(0),...
        num2str(this_mixdrift(2)), num2str(0),...
        num2str(0), num2str(this_mixdrift(3)),...
        num2str(this_mixdrift(4)), num2str(this_mixdrift(5)),...
        num2str(this_mixdrift(6)), num2str(this_mixdrift(7)),...
        num2str(this_mixdrift(8)),num2str(0)};
    this_line = strjoin(this_line, ', ');
    fprintf(fp, [this_line '\n']);
end   
%% Close the file
  fclose(fp);
    
end


