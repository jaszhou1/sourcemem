% Screen('Preference', 'SkipSyncTests', 1);
screen = init_ptb('max', 128, false);
ShowCursor;
% Colour parameters.
%
word = 'TEST';
circle_radius_px = 191; % computed 20px as being around 6% of the circle
circle_thickness_px = 3;
cross_size_px = 25;
cross_thickness_px = 5;
word_colour = [255, 255, 255];
circle_colour = [64, 64, 64];
cross_colour = [0, 0, 0];

oval_rect = screen.centre_fn(circle_radius_px * 2, ...
    circle_radius_px * 2);d
% Sizing/positioning parameters.
circle_radius_px = 191; % computed 20px as being around 6% of the circle
circle_thickness_px = 3;

font_name = 'Courier New';
word_size_px = 28;

angle = pi/2;

[cross_centre_x, cross_centre_y] = pol2cart(angle, circle_radius_px);
cross_centre_x = cross_centre_x + screen.centre(1);
cross_centre_y = cross_centre_y + screen.centre(2);
cross_rect = screen.rect_fn(cross_centre_x, cross_centre_y, ...
    cross_size_px, cross_size_px);

[normBoundsRect] = Screen('TextBounds', screen.win, word);
wordWidth = normBoundsRect(3);
wordHeight = normBoundsRect(4);

word_centre_x = cross_centre_x;
word_centre_y = cross_centre_y;

Screen('FrameOval', screen.win, circle_colour, oval_rect, ...
    circle_thickness_px);
Screen('DrawLine', screen.win, cross_colour, ...
    cross_rect(1), cross_rect(2), cross_rect(3), cross_rect(4), ...
    cross_thickness_px);
Screen('DrawLine', screen.win, cross_colour, ...
    cross_rect(3), cross_rect(2), cross_rect(1), cross_rect(4), ...
    cross_thickness_px);

Screen('TextSize', screen.win, word_size_px);
Screen('TextFont', screen.win, font_name);

% Write Text in Text Box

% DrawFormattedText(screen.win, word, word_centre_x, ...
%     word_centre_y, word_colour);
DrawFormattedText(screen.win, word, 'center', ...
    'center', word_colour);

 Screen('Flip', screen.win);
 WaitSecs(1);
 
 KbWait;
 sca;