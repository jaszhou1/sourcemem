function design = generate_source_memory_design(seed, par, word_list)
%GENERATE_SOURCE_MEMORY_DESIGN Generate source memory design structure
%   Generate the factorial (block and trial) structure for the source
%   memory experiment. As we can't follow Harlow and Donaldson's design
%   exactly (as the constraints don't seem to be clear from the
%   manuscript), we will approximate the design with heterogeneous
%   blocks and foil trials.
%
%   Previous experiment used long/short test delay conditions. These have
%   been dropped so all items are tested after a short delay. However,
%   items will be conditioned on Short (original) study time or Long
%   (doubled) study time.
%
% Simon Lilburn <lilburns AT unimelb DOT edu DOT au>

% Set the seed for the MATLAB random number generator.
rng(seed, 'twister');

% Make an empty space for the design variables to live.
design = struct();


% Compute the number of blocks, trials, etc.
num_blocks = par.num_blocks;
num_encode_trials = par.num_encode_trials;
num_test_trials = par.num_test_trials;
num_words = size(word_list(:,1), 1);
total_num_stim = num_blocks * num_encode_trials;
total_num_foil = total_num_stim;
total_num = total_num_stim + total_num_foil;

% Shuffle the indices for the word list
shuffle = randperm(num_words);
stim_index = shuffle(1:total_num_stim);
foil_index = shuffle(total_num_stim+1:end); % Indexes for words not already used to stimuli
foil_index = foil_index(1:total_num_foil); % Only need this many foils.

% Assigning words in

stim = word_list(stim_index)';
foil = word_list(foil_index)';


% Add angles to word list.
stim_cells = cell(total_num_stim, 3);
stim_cells(:, 1) = stim;
recog_list = cell(num_blocks, 1);
test_list = cell(num_blocks, 1);
num_words = num_encode_trials;
recog_words_total = num_words * 2;
encode_list = cell(num_blocks, 1);

% Does the experiment begin with sequential or simultaneous? Coin flip
block_start = binornd(1,0.5);
cond = mod(1:num_blocks+1,2);
if block_start == 0
    cond = cond(1:num_blocks);
else
    cond = cond(2:end);
end

% Generate the stimuli and foil components
 stim_cells(:, 2) = num2cell(2 * pi * rand(total_num_stim, 1) - pi);
 stim_cells(:, 3) = repmat({'STIM'}, [total_num_stim, 1]);


foil_cells = cell(total_num_foil, 4);
foil_cells(:, 1) = foil;
foil_cells(:, 2) = num2cell(2 * pi * rand(total_num_foil, 1) - pi); % Unneeded, but keeping dimensions same
foil_cells(:, 3) = repmat({'FOIL'}, [total_num_foil, 1]);
foil_cells(:, 4) = repmat({'NA'}, [total_num_foil, 1]);


        
for i = 1:num_blocks %Allocate in blocks
    
    word_offset = (i - 1) * num_encode_trials;
    %     word_limit = i * num_encode_trials;   
    % For each block, generate an encode list and a test list.
    % this was 1
    
    %   Encode Words
    encode_word_idx = (word_offset+1):(word_offset + num_words);
    block_encode_words = stim_cells(encode_word_idx, :);
    
    % Allocate Encode Condition
    if cond(i) == 1
        block_encode_words(:, 4) = repmat({'SEQUENTIAL'}, [num_words, 1]);%Sequential or Simultaneous
    else
        block_encode_words(:, 4) = repmat({'SIMULTANEOUS'}, [num_words, 1]);
    end
    
    % Create the encode word list.
    encode_list{i, :} = block_encode_words;
    
    
    % Create the recognition word list
    recog_list{i, :} = [ recog_list{i, :}; block_encode_words];
    
    % Create the test word list.
    test_list{i, :} = [ test_list{i, :}; block_encode_words];
    
end

% Fill recognition list with an equal number of foil words.
foil_offset = 1;
for i = 1:num_blocks
    recog_block = recog_list{i, :};
    num_foils = recog_words_total - size(recog_block, 1);
    if num_foils > 0
        foil_idx = foil_offset:(foil_offset + num_foils - 1);
        recog_block = [ recog_block; foil_cells(foil_idx, :) ];
        recog_list{i, :} = recog_block;
        foil_offset = foil_offset + num_foils;
    end
    recog_list{i, :} = recog_block;
end

% % Scramble each of the encode and test lists. It wont be scrambled in the
% function workspace, this is whats handed out to
% source_memory_experiment.

design.encode_list = cellfun(@(x) x(randperm(size(x, 1)), :), ...
    encode_list, 'UniformOutput', false);
design.recog_list = cellfun(@(x) x(randperm(size(x, 1)), :), recog_list, ...
    'UniformOutput', false);
design.test_list = cellfun(@(x) x(randperm(size(x, 1)), :), test_list, ...
    'UniformOutput', false);

% Put the seed into the design itself.

end
