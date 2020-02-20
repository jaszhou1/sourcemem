function [ ] = intertrial_wait(screen, wait_time)
%INTERTRIAL_WAIT Wait for a specified time on a uniform field.
%   Show a uniform field for a specified time.
%
% Simon Lilburn <lilburns AT unimelb DOT edu DOT au>

vbl = Screen('Flip', screen.win);
Screen('Flip', screen.win, vbl + (wait_time/1000));

end
