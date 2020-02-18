% run_source_simultaneous.m
%
% The overall script for running a session of the revised source memory experiment.
% This script asks the experimenter for all of the information required to
% run the experiment, and takes the necessary parameters and wordlists to
% run the experiment.
%
% (1) Revised word stimuli source, (2) made word and location display
% simultaneously, (3) added "too fast" response gating, (4) removed
% short/long display duration & low/high imageability manipulations
%
% Jason Zhou <jasonz1 AT unimelb DOT edu DOT au> 
% based on original code Simon Lilburn <lilburns AT unimelb DOT edu DOT au>

%% Get some system characteristics.
os = getenv('OS');

%% Set the main parameters for running the experiment (directories, etc.)
VERSION = '1.0';

if ispc
        ROOT_DIRECTORY = 'C:\Users\jasonz1\Documents\MATLAB\Experiment 1\simultaneous';
        DIR_SEP = '/';
elseif isunix
      ROOT_DIRECTORY = '~/sourcemem/experiment/code/simultaneous';
        DIR_SEP = '/';
% elseif ismac
     % Code to run on Mac platform
else
      error(['Unknown operating system from environment variable: ', ...
      os]);
end


% switch os
%     case {'Windows_NT'} % Are we still running in windows environment?
%         ROOT_DIRECTORY = %'C:\Users\jasonz1\Documents\MATLAB\Experiment 1\Imageability';
%         DIR_SEP = '/';
%     otherwise
%         error(['Unknown operating system from environment variable: ', ...
%             os]);
% end
        
TEMP_DIRECTORY = [ROOT_DIRECTORY DIR_SEP 'temp'];
OUTPUT_DIRECTORY = [ROOT_DIRECTORY DIR_SEP 'output'];
WORD_LIST_DIRECTORY = [ROOT_DIRECTORY DIR_SEP 'word-lists'];
word_list = readtable([WORD_LIST_DIRECTORY DIR_SEP 'wordlist.txt']);
word_list = word_list{:, 1};

%% Show welcome banner.
disp('Second source memory experiment for Jason Zhou''s PhD Thesis.');
disp(['Version ' VERSION]);
disp('=====');

%% Get experimenter input for running the experiment.
subj_number = input('Subject number? ');

%% Run the actual experiment with the given parameters.
date_string = datestr(now(), 'YYYY-mm-dd--HH-MM-SS');
SEED = randseed();
disp(['Using random seed: ' num2str(SEED) '.']);
session_data = source_memory_experiment(SEED, subj_number, ...
    TEMP_DIRECTORY, date_string, word_list, DIR_SEP);

%% Save a final copy of the session data.
output_filename = [OUTPUT_DIRECTORY DIR_SEP 'subj-' ...
    num2str(subj_number) '--' date_string '.dat'];
output_mat_filename = [OUTPUT_DIRECTORY DIR_SEP 'subj-' ...
    num2str(subj_number) '--' date_string '.mat'];
save(output_mat_filename, 'session_data');
save_source_memory_data(session_data, output_filename, VERSION);

%Just a cheeky boi to make csv real quick for analysis in R
csv_filename = [OUTPUT_DIRECTORY DIR_SEP 'subj-' ...
    num2str(subj_number) '--' date_string '.csv'];
session_data_to_csv(csv_filename, session_data)
