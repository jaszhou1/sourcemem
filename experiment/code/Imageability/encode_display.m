function actual_display_time = encode_display(screen, par, angle, ...
    is_repeat)
%ENCODE_DISPLAY Display the angle encoding phase in a source memory exp.
%   Display the angle element to be retained by a participant in the source
%   memory experiment.
%
% Simon Lilburn <lilburns AT unimelb DOT edu DOT au>

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
trial_start = Screen('Flip', screen.win);
vbl = trial_start;

% Display the angle until the end of the angle encoding period.
if is_repeat
    display_time = par.angle_repeat_duration_ms / 1000;
else
    display_time = par.angle_display_duration_ms / 1000;
end


while vbl - trial_start < display_time
    Screen('FrameOval', screen.win, par.circle_colour, oval_rect, ...
        par.circle_thickness_px);
    Screen('DrawLine', screen.win, par.cross_colour, ...
        cross_rect(1), cross_rect(2), cross_rect(3), cross_rect(4), ...
        par.cross_thickness_px);
    Screen('DrawLine', screen.win, par.cross_colour, ...
        cross_rect(3), cross_rect(2), cross_rect(1), cross_rect(4), ...
        par.cross_thickness_px);
    vbl = Screen('Flip', screen.win);
end

actual_display_time = vbl - trial_start;

end