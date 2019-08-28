function data = source_memory_encode_trial(screen, par, word, angle, type, cond)
%SOURCE_MEMORY_ENCODE_TRIAL Main function for source memory trial (encode)
%   Provides the interface for a trial in the encode phase of the source
%   memory experiment.
%
% Simon Lilburn <lilburns AT unimelb DOT edu DOT au>

% Display fixation cross in the centre of the screen.
encode_fixation(screen, par);
%% Modification 27/08
% Display word and angle on same screen

% % Display the encode angle and word display.
 encode_display_time = encode_word_angle(screen, par, angle, word, false);
% 
% Display the angle verification display.
[mouse_angle, mouse_radius, response_time, ...
    angular_error, mouse_trajectory] = ...
    encode_reproduce(screen, par, angle);
%% 

% If angular error is too high, redisplay the encode angle and reverify.
need_repeat = abs(angular_error) > par.max_encode_reproduction_error_rad;
while need_repeat
    % Need to put an error display for the participant.
    encode_accuracy_error(screen, par);
    
    % Repeat the angle.
    encode_word_angle(screen, par, angle, word, true);
    
    % Get the participant to reproduce the angle.
    [this_angle, this_radius, this_rt, ...
        this_error] = encode_reproduce(screen, par, angle);
    
    % Put the new reproduction data into the returned data.
    mouse_angle = [mouse_angle, this_angle];
    mouse_radius = [mouse_radius, this_radius];
    response_time = [response_time, this_rt];
    this_error = [angular_error, this_error];
    
    % Should we repeat again?
    need_repeat = abs(this_error) > par.max_encode_reproduction_error_rad;
end

% Package up all of the data.
data = struct();
data.word = word;
data.target_angle = angle;
data.type = type;
data.cond = cond;
data.encode_display_time = encode_display_time;
data.word_display_time = word_display_time;
data.reproduction_angle = mouse_angle;
data.reproduction_radius = mouse_radius;
data.reproduction_rt = response_time;
data.reproduction_error = angular_error;
data.mouse_trajectory = mouse_trajectory;

end
