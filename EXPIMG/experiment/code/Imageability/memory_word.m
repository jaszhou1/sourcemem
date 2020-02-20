function actual_display_time = memory_word(screen, par, word)
%MEMORY_WORD Display the word in the memory phase of the source memory exp.
%   Display the word element to be used as a recall cue in the memory phase
%   of the source memory experiment.
%
% Simon Lilburn <lilburns AT unimelb DOT edu DOT au>

% Initial flip to get trial start time.
Screen('TextSize', screen.win, par.word_size_px);
Screen('TextFont', screen.win, par.font_name);
DrawFormattedText(screen.win, word, 'center', ...
	'center', par.word_colour);
trial_start = Screen('Flip', screen.win);
vbl = trial_start;

% Display the text until the end of the display period.
while vbl - trial_start < (par.word_encoding_ms / 1000)
    DrawFormattedText(screen.win, word, 'center', ...
        'center', par.word_colour);
    vbl = Screen('Flip', screen.win);
end

actual_display_time = vbl - trial_start;

end