function data = source_memory_memory_trial(screen, par, word, angle, type, cond)
%SOURCE_MEMORY_MEMORY_TRIAL Main function for source memory trial (memory)
%   Provides the interface for a trial in the memory phase of the source
%   memory experiment.
%
% Simon Lilburn <lilburns AT unimelb DOT edu DOT au>

% Display a fixation cross.
memory_fixation(screen, par);

% Display the recall word.
word_display_time = memory_word(screen, par, word);

% Obtain the recalled angle from the participant.
[mouse_angle, mouse_radius, response_time, ...
    angular_error, mouse_trajectory] = ...
    memory_reproduce(screen, par, angle);

% Obtain a confidence rating from the participant. not collecting this for
% source
%[confidence_prop, conf_response_time] = ...
    %memory_confidence(screen, par);

% Package up the data.
data = struct();
data.word = word;
data.target_angle = angle;
data.type = type;
data.cond = cond;
data.word_display_time = word_display_time;
data.reproduction_angle = mouse_angle;
data.reproduction_radius = mouse_radius;
data.reproduction_rt = response_time;
data.reproduction_error = angular_error;
data.mouse_trajectory = mouse_trajectory;

end
