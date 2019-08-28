function [] = encode_accuracy_error(screen, par)
%ENCODE_ACCURACY_ERROR Feedback for participant in encoding stage.
%   Display some feedback for the participant in the encoding stage to
%   indicate that the angle has not been correctly reproduced.
%
% Simon Lilburn <lilburns AT unimelb DOT edu DOT au>

% Make the oval bounding box.
oval_rect = screen.centre_fn(par.circle_radius_px * 2, ... 
    par.circle_radius_px * 2);

% Show the inactive circle with the error message.
Screen('TextSize', screen.win, par.word_size_px);
Screen('TextFont', screen.win, par.font_name);
Screen('FrameOval', screen.win, par.inactive_circle_colour, oval_rect, ...
    par.circle_thickness_px);
DrawFormattedText(screen.win, 'TRY AGAIN', 'center', 'center', ...
    par.error_text_colour);
trial_start = Screen('Flip', screen.win);

% Show the circle and error for the specified duration.
Screen('TextSize', screen.win, par.word_size_px);
Screen('TextFont', screen.win, par.font_name);
Screen('FrameOval', screen.win, par.inactive_circle_colour, oval_rect, ...
    par.circle_thickness_px);
DrawFormattedText(screen.win, 'TRY AGAIN', 'center', 'center', ...
    par.error_text_colour);
Screen('Flip', screen.win, ...
    trial_start + (par.encode_error_duration_ms / 1000));

end

