function actual_display_time = recog_word(screen, par, word)
%RECOG_WORD Display the word encoding phase in a source memory exp.
%   Display the word element to be displayed in the recognition phase of the
%   source memory experiment.

% Initial flip to get trial start time.
Screen('TextSize', screen.win, par.word_size_px);
Screen('TextFont', screen.win, par.font_name);
DrawFormattedText(screen.win, word, 'center', ...
	'center', par.word_colour);
trial_start = Screen('Flip', screen.win);
vbl = trial_start;

% Display the text until the end of the encoding period.
    while vbl - trial_start < (par.word_encoding_ms / 1000)
        DrawFormattedText(screen.win, word, 'center', ...
            'center', par.word_colour);
        vbl = Screen('Flip', screen.win);
    end

actual_display_time = vbl - trial_start;

end

