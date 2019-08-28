function design = generate_source_memory_design(seed, par, word_list_low, word_list_high)
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
num_words_low = size(word_list_low(:,1), 1);
num_words_high = size(word_list_high(:,1), 1);
num_words = num_words_low + num_words_high;
total_num_stim = num_blocks * num_encode_trials;
total_num_foil = total_num_stim;
total_num = total_num_stim + total_num_foil; % I know this seems dumb, but i thought it would be consistent

% Number of each type of word
num_low_stim = total_num_stim/2;
num_high_stim = total_num_stim/2;
num_low_foil = total_num_foil/2;
num_high_foil = total_num_foil/2;

% Shuffle the indices for the word list- high and low encode

high_subset = randperm(num_words_high);
low_subset = randperm(num_words_low);

high_stim_index = high_subset(1:num_high_stim);
low_stim_index = low_subset(1:num_low_stim);
high_foil_index = high_subset(num_high_stim+1:end);
    high_foil_index = high_foil_index(1:num_high_foil); % I dont need 625 foils, just 60.
low_foil_index = low_subset(num_low_stim+1:end); 
    low_foil_index = low_foil_index(1:num_low_foil);

% Assigning words in

high_stim = word_list_high(high_stim_index)';
    high_stim(:, 2) = repmat({'HIGH'}, num_high_stim, 1);
high_foil = word_list_high(high_foil_index)';
    high_foil(:, 2) = repmat({'HIGH'}, num_high_foil, 1);
low_stim = word_list_low(low_stim_index)';
    low_stim(:, 2) = repmat({'LOW'}, num_low_stim, 1);
low_foil = word_list_low(low_foil_index)';
    low_foil(:, 2) = repmat({'LOW'}, num_low_foil, 1);

% Put all stim and foil words into two strucs and shuffle
stim_words = [high_stim;low_stim;high_foil;low_foil];
stim_idx = randperm(total_num_stim);
stim_shuffle = stim_words(stim_idx, :);

foil_words = [high_foil;low_foil];
foil_idx = randperm(total_num_foil);
foil_shuffle = foil_words(foil_idx, :);
    
% Add angles to word list. 
stim_cells = cell(total_num_stim, 4);
stim_cells(:, 1) = stim_shuffle(:,1);
recog_list = cell(num_blocks, 1);
test_list = cell(num_blocks, 1); 
num_words = num_encode_trials;
recog_words_total = num_words * 2;

encode_list = cell(num_blocks, 1);
for i = 1:num_blocks
    
    word_offset = (i - 1) * num_encode_trials;
%     word_limit = i * num_encode_trials;
stim_cells(:, 2) = num2cell(2 * pi * rand(total_num_stim, 1) - pi);
stim_cells(:, 3) = repmat({'STIM'}, [total_num_stim, 1]);
stim_cells(:, 4) = stim_shuffle(:,2);

foil_cells = cell(total_num_foil, 3);
foil_cells(:, 1) = foil_shuffle(:,1);
foil_cells(:, 2) = num2cell(2 * pi * rand(total_num_foil, 1) - pi); % Unneeded, but keeping dimensions same
foil_cells(:, 3) = repmat({'FOIL'}, [total_num_foil, 1]);
foil_cells(:, 4) = foil_shuffle(:,2);


% For each block, generate an encode list and a test list.
 % this was 1
    
%   Encode Words  
    encode_word_idx = (word_offset+1):(word_offset + num_words);
    block_encode_words = stim_cells(encode_word_idx, :);
    
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
