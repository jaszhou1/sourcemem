function [mouse_angle, mouse_radius, response_time, ...
    angular_error, mouse_trajectory] = ...
    encode_reproduce(screen, par, target_angle)
%ENCODE_REPRODUCE Display the angle encoding phase in a source memory exp.
%   Display the angle element to be retained by a participant in the source
%   memory experiment.
%
% Simon Lilburn <lilburns AT unimelb DOT edu DOT au>

% Set an initial mouse position (relative to the centre).
SetMouse(screen.centre(1), screen.centre(2), screen.win);
mouse_x = 0.0;
mouse_y = 0.0;

% Make the oval bounding box.
oval_rect = screen.centre_fn(par.circle_radius_px * 2, ... 
    par.circle_radius_px * 2);

% Draw the initial frame to get the trial starting time.
Screen('FrameOval', screen.win, par.circle_colour, oval_rect, ...
    par.circle_thickness_px);
Screen('FillOval', screen.win, par.cursor_colour, ...
    screen.rect_fn(mouse_x + screen.centre(1), ...
                   mouse_y + screen.centre(2), ...
                   par.cursor_size_px, par.cursor_size_px));
trial_start = Screen('Flip', screen.win);
vbl = trial_start;

% Record the mouse trajectory for par.mouse_limit steps.
MOUSE_LIMIT = par.mouse_limit;
i = 1;
mouse_trajectory = NaN(2, MOUSE_LIMIT);

% Display the angle until the end of the angle encoding period.
within_bounds = true;

while within_bounds
    % Get the mouse coordinates.
    [raw_x, raw_y] = GetMouse(screen.win);
    mouse_x = raw_x - screen.centre(1);
    mouse_y = raw_y - screen.centre(2);    

    mouse_trajectory(:, i) = [mouse_x, mouse_y];
    i = mod(i, MOUSE_LIMIT) + 1;
    
    % Is the mouse outside of the circle radius.
    mouse_dist = sqrt(mouse_x.^2 + mouse_y.^2);
    if mouse_dist > par.circle_radius_px
        within_bounds = false;
    end
    
    % Draw the screen.
    Screen('FrameOval', screen.win, par.circle_colour, oval_rect, ...
    par.circle_thickness_px);
    Screen('FillOval', screen.win, par.cursor_colour, ...
            screen.rect_fn(mouse_x + screen.centre(1), ...
                           mouse_y + screen.centre(2), ...
                           par.cursor_size_px, par.cursor_size_px));
    vbl = Screen('Flip', screen.win);
end

% Compute the error.
[mouse_angle, mouse_radius] = cart2pol(mouse_x, mouse_y);
ang_diff = target_angle - mouse_angle;
angular_error = atan2(sin(ang_diff), cos(ang_diff));
response_time = vbl - trial_start;

end