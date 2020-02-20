function [] = test_octobox(word)
%TEST_OCTOBOX test function for alternative method for positioning words
%   Existing solution to putting words on the circle for source location is
%   to have crosses and words positioned away from the circle. The reason
%   for this is that putting words directly on the circle compromises
%   source precision in an unequal fashion (words are longer than they are
%   tall). This is designed to address that by partioning the circle into
%   eight sectors which determine which part of the text box to use to position
%   the word relative to the circle.
%%
% Screen('Preference', 'SkipSyncTests', 1);
screen = init_ptb('max', 128, false);
% Colour parameters.
%
word_colour = [255, 255, 255];
circle_colour = [64, 64, 64];
cross_colour = [0, 0, 0];



% Sizing/positioning parameters.
circle_radius_px = 191; % computed 20px as being around 6% of the circle
circle_thickness_px = 3;
cross_size_px = 25;
cross_thickness_px = 5;

font_name = 'Courier New';
word_size_px = 24;
%
secbound = linspace(-pi,pi,9);
secbound(9) = [];
secbound = secbound + (pi/8);

oval_rect = screen.centre_fn(circle_radius_px * 2, ...
    circle_radius_px * 2);

test_ang = linspace(-pi,pi);

for i = 1:100
    angle = test_ang(i);
    % Make the cross bounding box.
    [cross_centre_x, cross_centre_y] = pol2cart(angle, circle_radius_px);
    cross_centre_x = cross_centre_x + screen.centre(1);
    cross_centre_y = cross_centre_y + screen.centre(2);
    cross_rect = screen.rect_fn(cross_centre_x, cross_centre_y, ...
        cross_size_px, cross_size_px);
    %% Octobox
    
    % Make text bounding box
    
    %Find out handles
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
    %%
       
    % Draw initial frame to get the start of this part of the trial.
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
%     
    % Write Text in Text Box
    
    DrawFormattedText(screen.win, word, word_centre_x, ...
        word_centre_y, word_colour);
    
    Screen('Flip', screen.win);
    WaitSecs(1);
end
KbWait;
sca;
end
