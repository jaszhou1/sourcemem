function [ ] = source_memory_maths_intro(screen, par)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here
% Display the word "Maths" centred on the screen.
Screen('TextSize', screen.win, par.word_size_px); %.win a handle to ptb which window its drawing to
Screen('TextFont', screen.win, par.font_name);
DrawFormattedText(screen.win, 'Please Complete the Following Maths Problems', 'center', ...
	'center', par.word_colour);
trial_start = Screen('Flip', screen.win);
vbl = trial_start;

Screen('TextSize', screen.win, par.word_size_px); %doing it twice to get the start time- the second flip is the flip that ends the interval.
Screen('TextFont', screen.win, par.font_name);
DrawFormattedText(screen.win, 'Maths', 'center', ...
	'center', par.word_colour);
Screen('Flip', screen.win, vbl + (par.intro_time/1000)); 

end

