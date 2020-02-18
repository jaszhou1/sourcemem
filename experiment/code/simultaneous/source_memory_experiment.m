function data = source_memory_experiment(seed, subj_number, ...
    temp_directory, date_string, word_list_low, word_list_high, directory_separator)
%SOURCE_MEMORY_EXPERIMENT Main function for the entire source memory exp.
%   Provides the interface for the entire source memory experiment,
%   following the work of Harlow and Donaldson (2013).
%
% Simon Lilburn <lilburns AT unimelb DOT edu DOT au>
% Modified: Jason Zhou <jaszhou AT unimelb DOT edu DOT au>


% Get parameters for experiment.
par = source_memory_parameters(); %doesnt take any input, a constant

% Generate design for experiment.
design = generate_source_memory_design(seed, par, word_list_low, word_list_high);

% Initialise Psychtoolbox.
scr = init_ptb('max', 128, false);

% Some instructions for the participants.
source_memory_intro(scr, par);

% empty place to store each blocks' data
encode_data = [];
maths_data = {};
recog_data = [];
test_data = [];

for i = 1:par.num_blocks
    % Run the encoding phase of the experiment.
    source_memory_encode_intro(scr, par);
    this_block_encode = design.encode_list{i};
    num_encode_trials = size(this_block_encode, 1);
    this_block_encode_data = [];
    for j = 1:num_encode_trials
        encode_word = this_block_encode{j, 1};
        encode_angle = this_block_encode{j, 2};
        encode_type = this_block_encode{j, 3};
        encode_cond = this_block_encode{j, 4};
        
        % Simultaneous vs Sequential condition goes here
        if encode_cond == 'Sequential'
            this_block_encode_data = [this_block_encode_data ...
                source_memory_encode_trial_seq(scr, par, encode_word, encode_angle, encode_type, encode_cond)]; %new row for each trial
            intertrial_wait(scr, par.encode_iti_ms);
            
        elseif encode_cond == 'Simultaneous'
            this_block_encode_data = [this_block_encode_data ...
                source_memory_encode_trial_sim(scr, par, encode_word, encode_angle, encode_type, encode_cond)]; %new row for each trial
            intertrial_wait(scr, par.encode_iti_ms);
        end     
    end
    encode_data = [encode_data; this_block_encode_data]; %new row for reach block.
    
    % Run distractor task (30 seconds of Maths)
    
    %Show some instructions
    source_memory_maths_intro(scr, par);
    this_block_maths_data = maths_distractor(scr, 30);
    
    %have a maths data struc overall, append the new block at the end.
    %otherwise, at the end it would only be data from the last
    %block.
    
    maths_data = [maths_data; this_block_maths_data];
    %{} is cell array, I have declared this as a cell array but Can just use [] anyway, this
    %prevents an empty array at the start
    
    
    %     % Run the recognition memory phase of experiment
    source_memory_recog_intro(scr, par);
    this_block_recog = design.recog_list{i}; %make a new design.recog_list? done. %This doesn't work- I need foils for a recognition. Generate these in the design.
    num_recog_trials = size(this_block_recog, 1);
    this_block_recog_data = [];
    
    for j = 1:num_recog_trials
        recog_word = this_block_recog{j, 1};
        recog_word_type = this_block_recog{j, 3};
        recog_word_cond = this_block_recog{j, 4};
        this_block_recog_data = [this_block_recog_data ...
            source_memory_recog_trial(scr, par, recog_word, recog_word_type, recog_word_cond)];
        intertrial_wait(scr, par.encode_iti_ms);
    end
    %
    recog_data = [recog_data; this_block_recog_data];
    
    % Run the memory phase of the experiment.
    
    source_memory_memory_intro(scr, par);
    this_block_test = design.test_list{i};
    num_test_trials = size(this_block_test, 1);
    this_block_test_data = [];
    for j = 1:num_test_trials
        test_word = this_block_test{j, 1};
        test_angle = this_block_test{j, 2};
        test_word_type = this_block_test{j, 3};
        test_word_cond = this_block_test{j, 4};
        this_block_test_data = [this_block_test_data ...
            source_memory_memory_trial(scr, par, test_word, test_angle, test_word_type, test_word_cond)];
        intertrial_wait(scr, par.test_iti_ms);
    end
    test_data = [test_data; this_block_test_data];
    
    % Write a temporary file out.   %why and how do i shove more stuff in
    % here
    save([temp_directory directory_separator 'temp-subj-' ...
        num2str(subj_number) '-block-' num2str(i) '--' ...
        date_string '.mat'], 'par', 'design', 'encode_data', ...
        'test_data');
    
    
end

% Shut down Psychtoolbox.
sca;



% Package up the data for writing the full data file.
data = struct();
data.seed = seed;
data.parameters = par;
data.encode_trials = encode_data;
data.maths = maths_data;
data.recog = recog_data;
data.test_trials = test_data;
data.design = design;
end
