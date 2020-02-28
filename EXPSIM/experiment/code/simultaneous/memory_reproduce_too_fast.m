function [] = memory_reproduce_too_fast(screen, par)
% Display the word "Recognition" centred on the screen.
Screen('TextSize', screen.win, par.word_size_px); %.win a handle to ptb which window its drawing to
Screen('TextFont', screen.win, par.font_name);
DrawFormattedText(screen.win, 'TOO FAST', 'center', ...
	'center', par.error_text_colour);
trial_start = Screen('Flip', screen.win);
vbl = trial_start;

Screen('TextSize', screen.win, par.word_size_px); %doing it twice to get the start time- the second flip is the flip that ends the interval.
Screen('TextFont', screen.win, par.font_name);
DrawFormattedText(screen.win, 'TOO FAST', 'center', ...
	'center', par.error_text_colour);
Screen('Flip', screen.win, vbl + (5)); 

end
