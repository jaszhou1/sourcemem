function actual_display_time = encode_word_angle(screen, par, angle, word, is_repeat)
%% ENCODE_WORD_ANGLE
%   Alternate version of encoding phase for
%   Jason Zhou's source memory project. Here, words are displayed at their
%   source location (at an angle beyond the bounding circle corresponding
%   to the cross)
%   rather than being temporally and spatially distinct
%   from their source.
%%
% Make the oval bounding box.
oval_rect = screen.centre_fn(par.circle_radius_px * 2, ...
    par.circle_radius_px * 2);

% Cut the circle into sections
secbound = linspace(-pi,pi,9);
secbound(9) = [];
secbound = secbound + (pi/8);

% Make the cross bounding box.
[cross_centre_x, cross_centre_y] = pol2cart(angle, par.circle_radius_px);
cross_centre_x = cross_centre_x + screen.centre(1);
cross_centre_y = cross_centre_y + screen.centre(2);
cross_rect = screen.rect_fn(cross_centre_x, cross_centre_y, ...
    par.cross_size_px, par.cross_size_px);

% Make text bounding box

% Make text bounding box

[normBoundsRect] = Screen('TextBounds', screen.win, word);

% Figure out which handle of the text box to use
wordWidth = normBoundsRect(3);
wordHeight = normBoundsRect(4);

if (secbound(2) > angle) && (angle >= secbound (1))
    word_centre_x = cross_centre_x-(wordWidth+20);
    word_centre_y = cross_centre_y-(wordHeight-15);
elseif (secbound(3) > angle) && (angle >= secbound (2))
    word_centre_x = cross_centre_x-(wordWidth/2);
    word_centre_y = cross_centre_y - 20;
elseif (secbound(4) > angle) && (angle >= secbound (3))
    word_centre_x = cross_centre_x + 15;
    word_centre_y = cross_centre_y -5;
elseif (secbound(5) > angle) && (angle >= secbound (4))
    word_centre_x = cross_centre_x + 20;
    word_centre_y = cross_centre_y + 8;
elseif (secbound(6) > angle) && (angle >= secbound (5))
    word_centre_x = cross_centre_x + 15;
    word_centre_y = cross_centre_y + 20;
elseif (secbound(7) > angle) && (angle >= secbound (6))
    word_centre_x = cross_centre_x -(wordWidth/2);
    word_centre_y = cross_centre_y + 40;
elseif (secbound(8) > angle) && (angle >= secbound (7))
    word_centre_x = cross_centre_x- (wordWidth+20);
    word_centre_y = cross_centre_y + (wordHeight+4);
else
    word_centre_x = cross_centre_x -(wordWidth+20);
    word_centre_y = cross_centre_y + 8;
end

% Draw initial frame to get the start of this part of the trial.
Screen('FrameOval', screen.win, par.circle_colour, oval_rect, ...
    par.circle_thickness_px);

Screen('DrawLine', screen.win, par.cross_colour, ...
    cross_rect(1), cross_rect(2), cross_rect(3), cross_rect(4), ...
    par.cross_thickness_px);
Screen('DrawLine', screen.win, par.cross_colour, ...
    cross_rect(3), cross_rect(2), cross_rect(1), cross_rect(4), ...
    par.cross_thickness_px);

% Write Text in Text Box

DrawFormattedText(screen.win, word, word_centre_x, ...
    word_centre_y, par.word_colour);

trial_start = Screen('Flip', screen.win);
vbl = trial_start;

% Display the word and angle until the end of the angle encoding period.
if is_repeat
    display_time = par.word_encoding_ms / 1000;
else
    display_time = par.word_encoding_ms / 1000;
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
    DrawFormattedText(screen.win, word, word_centre_x, ...
        word_centre_y, par.word_colour);
    vbl = Screen('Flip', screen.win);
end

actual_display_time = vbl - trial_start;

end

