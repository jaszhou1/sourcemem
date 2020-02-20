function [ ] = source_memory_intro(screen, par)
%SOURCE_MEMORY_INTRO Instruction screen for source memory experiment
%   Displays the introductory and instruction screen for the entire source
%   memory experiment.
%
% Simon Lilburn <lilburns AT unimelb DOT edu DOT au>

img = imread('instruction1.png');

tex_handle = Screen('MakeTexture', screen.win, img);
Screen('DrawTexture', screen.win, tex_handle);

% Display on screen until mouse is clicked.
[~, ~, mouse_button] = GetMouse(screen.win);
while any(mouse_button)
    [~, ~, mouse_button] = GetMouse(screen.win);
end

not_entered = true;
while not_entered
    Screen('DrawTexture', screen.win, tex_handle);
    Screen('Flip', screen.win);
    [~, ~, mouse_button] = GetMouse(screen.win);
    if any(mouse_button) 
        not_entered = false;
    end
end

end
