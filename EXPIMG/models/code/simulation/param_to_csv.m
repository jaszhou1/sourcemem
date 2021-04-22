function [] = param_to_csv(filename, participants, Cont, Thresh, Generator, gen_is_cont)
%PARAM_TO_CSV Output a CSV file from .MAT structure that has the parameter
%estimates for the continuous, threshold and hybrid models in a way that is
%easy to compare across participant and models
%% Open the file
fp = fopen(filename, 'w');

%% Print the header line in the CSV.
header_line = 'participant, model_name, BIC, v1, v2, eta, a1, a2, pi, Ter, st, sa';
fprintf(fp, [header_line '\n']);


%% Write parameter

for i = participants
    
    %% There appears to be a strange observer without any data in them, so
    % %      let's skip over anyone who doesn't seem to have data.
    if isempty(Cont{i,1})
        continue
    end
    
    %% Get the appropriate model parameters
    %troubleshooting
    disp('Participant')
    disp(i);
    
    % Generating model
    this_gen = Generator{i,4};
    if gen_is_cont == 1
        this_line = { num2str(i), 'Generating', 'NA',...
            num2str(this_gen(1)), num2str(0),...
            num2str(this_gen(2)),num2str(this_gen(3)),...
            num2str(0),num2str(0),...
            num2str(this_gen(4)), num2str(this_gen(5)),...
            num2str(0)};
        this_line = strjoin(this_line, ', ');
        fprintf(fp, [this_line '\n']);
    else
            this_line = { num2str(i), 'Generating', 'NA',...
        num2str(this_gen(1)), num2str(0),...
        num2str(0),num2str(this_gen(2)),...
        num2str(this_gen(3)),num2str(this_gen(4)),...
        num2str(this_gen(5)),num2str(this_gen(6)),...
        num2str(0)};
    this_line = strjoin(this_line, ', ');
    fprintf(fp, [this_line '\n']);
    end
    
    % Continuous
    this_cont = Cont{i,4};
    
    this_line = { num2str(i), 'Continuous',num2str(Cont{i,2}),...
        num2str(this_cont(1)), num2str(0),...
        num2str(this_cont(2)),num2str(this_cont(3)),...
        num2str(0),num2str(0),...
        num2str(this_cont(4)), num2str(this_cont(5)),...
        num2str(0)};
    this_line = strjoin(this_line, ', ');
    fprintf(fp, [this_line '\n']);
    
    % Threshold
    this_thresh = Thresh{i,4};
    
    this_line = { num2str(i), 'Threshold',num2str(Thresh{i,2}),...
        num2str(this_thresh(1)), num2str(0),...
        num2str(0),num2str(this_thresh(2)),...
        num2str(this_thresh(3)),num2str(this_thresh(4)),...
        num2str(this_thresh(5)),num2str(this_thresh(6)),...
        num2str(0)};
    this_line = strjoin(this_line, ', ');
    fprintf(fp, [this_line '\n']);
    
end
%% Close the file
fclose(fp);

end

