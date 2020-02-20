function [ confidence_prop, confidence_rt ] = ... 
    memory_confidence(screen, par)
%MEMORY_CONFIDENCE Confidence elicitation for previously recalled angle
%   A confidence response display for the recently recalled angle in the
%   memory phase of a source memory experiment.
%
% Simon Lilburn <lilburns AT unimelb DOT edu DOT au>

% Define the confidence bar (background) bounding box.
confidence_bound_box = screen.rect_fn(screen.centre(1), ...
    screen.centre(2) + par.confidence_vert_offset_px, ...
    par.confidence_height_px, par.confidence_length_px);
prop_clamp_fn = ...
    @(p) (max(0, min(1, p)));
confidence_bar_position_fn = ...
    @(p) (prop_clamp_fn(p) * ...
     (par.confidence_length_px) + ...
      confidence_bound_box(RectLeft));
confidence_bar_rect_fn = ...
    @(p) (screen.rect_fn(confidence_bar_position_fn(p), ...
      screen.centre(2) + par.confidence_vert_offset_px, ...
      par.confidence_bar_height_px, ...
      par.confidence_bar_width_px));
position_to_prop_fn = ...
    @(x) (prop_clamp_fn((x - confidence_bound_box(RectLeft)) / ...
           par.confidence_length_px));
  
% Jitter the mouse position.
start_prop = rand();
SetMouse(confidence_bar_position_fn(start_prop), ...
    screen.centre(2) + par.confidence_vert_offset_px, ...
    screen.win);

% Display the instruction to the participant.
Screen('TextSize', screen.win, par.word_size_px);
Screen('TextFont', screen.win, par.font_name);
DrawFormattedText(screen.win, 'How confident are you?', ...
    'center', 'center', par.word_colour);

% Display the confidence bar (and bar background).
[mouse_x, ~, mouse_button] = GetMouse(screen.win);
Screen('FillRect', screen.win, par.confidence_bar_back, ...
    confidence_bound_box);
Screen('FillRect', screen.win, par.confidence_bar_front, ...
    confidence_bar_rect_fn(mouse_x));

while any(mouse_button)
    [~, ~, mouse_button] = GetMouse(screen.win);
end

% Get the initial time with the first flip.
trial_start = Screen('Flip', screen.win);

% Until click, display confidence bar.
not_entered = true;
while not_entered
    % Draw text.
    Screen('TextSize', screen.win, par.word_size_px);
    Screen('TextFont', screen.win, par.font_name);
    DrawFormattedText(screen.win, 'How confident are you?', ...
        'center', 'center', par.word_colour);
    
    % Draw bar.
    [mouse_x, ~, mouse_button] = GetMouse(screen.win);
    Screen('FillRect', screen.win, par.confidence_bar_back, ...
        confidence_bound_box);
    Screen('FillRect', screen.win, par.confidence_bar_front, ...
        confidence_bar_rect_fn(position_to_prop_fn(mouse_x)));
    
    vbl = Screen('Flip', screen.win);
    
    if any(mouse_button) 
        not_entered = false;
    end
end

confidence_rt = vbl - trial_start;
confidence_prop = position_to_prop_fn(mouse_x);

end

