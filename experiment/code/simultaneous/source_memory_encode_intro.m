function [ ] = source_memory_encode_intro(screen, par)
%SOURCE_MEMORY_ENCODE_INTRO Intro screen for encode phase
%   Displays the introductory screen for the encoding phase in a source
%   memory experiment.
%
% Simon Lilburn <lilburns AT unimelb DOT edu DOT au>

% Display the word "ENCODE" centred on the screen.
Screen('TextSize', screen.win, par.word_size_px);
Screen('TextFont', screen.win, par.font_name);
DrawFormattedText(screen.win, 'Encode phase', 'center', ...
	'center', par.word_colour);
trial_start = Screen('Flip', screen.win);
vbl = trial_start;

Screen('TextSize', screen.win, par.word_size_px);
Screen('TextFont', screen.win, par.font_name);
DrawFormattedText(screen.win, 'Encode phase', 'center', ...
	'center', par.word_colour);
Screen('Flip', screen.win, vbl + (par.intro_time/1000));

end
