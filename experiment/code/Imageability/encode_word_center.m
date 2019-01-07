function actual_display_time = encode_word_center(screen, par, word, cond)
%% ENCODE_WORD_CENTER
%   Alternate version of encoding phase of Experiment 1 (Study Time) for
%   Jason Zhou's source memory project. Here, words are displayed at their
%   source location, rather than being temporally and spatially distinct
%   from their source.
%%
% Make the oval bounding box.
oval_rect = screen.centre_fn(par.circle_radius_px * 2, ...
    par.circle_radius_px * 2);

% Make the cross bounding box.
[cross_centre_x, cross_centre_y] = pol2cart(angle, par.circle_radius_px);
cross_centre_x = cross_centre_x + screen.centre(1);
cross_centre_y = cross_centre_y + screen.centre(2);
cross_rect = screen.rect_fn(cross_centre_x, cross_centre_y, ...
    par.cross_size_px, par.cross_size_px);

% Draw initial frame to get the start of this part of the trial.
Screen('FrameOval', screen.win, par.circle_colour, oval_rect, ...
    par.circle_thickness_px);

Screen('DrawLine', screen.win, par.cross_colour, ...
    cross_rect(1), cross_rect(2), cross_rect(3), cross_rect(4), ...
    par.cross_thickness_px);
Screen('DrawLine', screen.win, par.cross_colour, ...
    cross_rect(3), cross_rect(2), cross_rect(1), cross_rect(4), ...
    par.cross_thickness_px);

% Write Text in Text Box (new!)

DrawFormattedText(screen.win, word, 'center', ...
    'center', par.word_colour);

trial_start = Screen('Flip', screen.win);
vbl = trial_start;

% Display the angle until the end of the angle encoding period.
z = strcmp (cond,'SHORT');
if z == 1 %Added this higher level loop to have condition display & repeat type on 'SHORT'/'LONG'.
    if is_repeat
        display_time = par.angle_repeat_duration_ms / 1000;
    else
        display_time = par.angle_display_duration_ms / 1000;
    end
else
    if is_repeat
        display_time = par.angle_repeat_duration_long_ms / 1000;
    else
        display_time = par.angle_display_duration_long_ms / 1000;
    end
end

while vbl - trial_start < display_time
    Screen('FrameOval', screen.win, par.circle_colour, oval_rect, ...
        par.circle_thickness_px);
    % Draw Cross
    Screen('DrawLine', screen.win, par.cross_colour, ...
        cross_rect(1), cross_rect(2), cross_rect(3), cross_rect(4), ...
        par.cross_thickness_px);
    Screen('DrawLine', screen.win, par.cross_colour, ...
        cross_rect(3), cross_rect(2), cross_rect(1), cross_rect(4), ...
        par.cross_thickness_px);
    % Write Text
    DrawFormattedText(screen.win, word, 'center', ...
        'center', par.word_colour);
    vbl = Screen('Flip', screen.win);
end

actual_display_time = vbl - trial_start;

end

