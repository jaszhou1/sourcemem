function [] = session_data_to_csv(filename, session_data)
%SESSION_DATA_TO_CSV Writes a session data file to CSV 
%   Opens a given filename, writes a header, and then outputs the session
%   data structure to plain text CSV.

%% Open the file.
fp = fopen(filename, 'w');

%% Write the header.
fprintf(fp, ['word, condition, recog_rating, recog_RT, target_angle, ' ...
    'response_angle, response_error, response_RT\n']);

%% Write each row to the file.
recog_data = session_data.recog;
source_data = session_data.test_trials;
for i = 1:size(recog_data, 1) % Blocks
   for j = 1:size(recog_data, 2) % Trials
       this_trial = recog_data(i, j);
       if strcmp(this_trial.type, 'FOIL')
           fprintf(fp, '%s, %s, %d, %6.4f, NA, NA, NA, NA\n', ...
               this_trial.word, this_trial.type, ...
               this_trial.recognition_rating, ...
               this_trial.recognition_response_time);
       else 
           this_source_trial = source_data(strcmp({source_data.word}, ...
               this_trial.word));
           fprintf(fp, '%s, %s, %d, %6.4f, %6.4f, %6.4f, %6.4f, %6.4f\n', ...
               this_trial.word, this_trial.type, ...
               this_trial.recognition_rating, ...
               this_trial.recognition_response_time, ...
               this_source_trial.target_angle, ...
               this_source_trial.reproduction_angle, ...
               this_source_trial.reproduction_error, ...
               this_source_trial.reproduction_rt);
       end       
   end
end

%% Close the file handle.
fclose(fp);


end

