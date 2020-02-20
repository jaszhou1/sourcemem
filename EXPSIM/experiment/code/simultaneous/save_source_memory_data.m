function [] = save_source_memory_data(data, filename, version)
%SAVE_SOURCE_MEMORY_DATA Saves a simple trial-by-trial data set.
%   Saves a simple trial-by-trial data set for analysis in R, SPSS, etc.
%   without having to use the MATLAB .mat files in the temp directory.
%
% Simon Lilburn <lilburns AT unimelb DOT edu DOT au>

% Get file pointer.
fp = fopen(filename, 'w');

% Save the heading.
fprintf(fp, ...
    ['# SOURCE MEMORY EXPERIMENT (version ' version ') DATA FILE\n']);
fprintf(fp, ...
    ['# =====\n']);
fprintf(fp, ...
    ['#\n']);
fprintf(fp, ...
    ['# Parameters\n']);
fprintf(fp, ...
    ['# -----\n']);
fprintf(fp, ...
    ['#\n']);

% Save the parameter values.
parameter_names = fieldnames(data.parameters);
for i = 1:length(parameter_names)
    field_name = parameter_names{i};
    field_data = getfield(data.parameters, field_name);
    field_data_string = evalc('disp(field_data)');
    fprintf(fp, ...
        ['#' field_name ':' field_data '\n']);
end

% Save the random seed.
fprintf(fp, ...
    ['# =====\n']);
fprintf(fp, ...
    ['#\n']);
fprintf(fp, ...
    ['# SEED: ' num2str(data.seed) '\n']); %"Reference to non-existent field 'seed'."

fprintf(fp, ...
    ['#\n']);

% Save each encode--memory block.
num_blocks = data.parameters.num_blocks;
num_encode_trials = data.parameters.num_encode_trials;
num_test_trials = data.parameters.num_test_trials;

for i = 1:num_blocks
    
    % Save the encode block.
    for j = 1:num_encode_trials
        encode_block = data.encode_trials(i, j);
        encode_string = ...
            [num2str(i) ', ENCODE, ' encode_block.word ', ' ...
            num2str(encode_block.target_angle) ', ' ...
            num2str(encode_block.reproduction_angle) ', ' ...
            num2str(encode_block.reproduction_rt) ', ' ...
            num2str(encode_block.reproduction_error)];
        
        fprintf(fp, ...
            [encode_string '\n']);
    end
    
    %   Save the maths block
    for j = 1:size(data.maths{i},2)
        %Becase the number of "trials" in the maths distractor will vary
        %from block to block (its based on duration, not number of trials)
        %this is here so it will save from 1 to whatever the number of
        %rows is in that array.
        encode_string = ...
            [num2str(i) ', MATHS'];
        
        fprintf(fp, ...
            [encode_string '\n']);
    end
    
    % Save the test block.
    for j = 1:num_test_trials
        test_block = data.test_trials(i, j);
        test_string = ...
            [num2str(i) ', TEST, ' test_block.word ', ' ...
            num2str(test_block.target_angle) ', ' ...
            num2str(test_block.reproduction_angle) ', ' ...
            num2str(test_block.reproduction_rt) ', ' ...
            num2str(test_block.reproduction_error)];
        %num2str(test_block.confidence_prop) ', ' ...
        %num2str(test_block.confidence_rt)];
        fprintf(fp, ...
            [test_string '\n']);
    end
end
% Close the file for writing.
fclose(fp);

end 



