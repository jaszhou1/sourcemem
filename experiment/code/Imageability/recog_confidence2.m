function [ recog_rating, recog_response_time ] = ... 
    recog_confidence2(screen, par)
%RECOG_CONFIDENCE. A six-point Old/New judgement for items in previously
%encoded word lists. Equal number of target items and lures. Used to obtain
%recognition confidence ratings that we can condition source responses on.
% Jason Zhou <jasonz1 AT student DOT unimelb DOT edu DOT au>
%% Define Stuff

% Define Center
[xCenter, yCenter] = RectCenter(screen.rect);

% Word size and font
Screen('TextSize', screen.win, par.word_size_px);
Screen('TextFont', screen.win, par.font_name);
%% Initial display

%Display instructions

DrawFormattedText(screen.win, ['Is this word OLD or NEW?\n\n' 'TEST WORD'], ...
    'center', 'center', par.word_colour);

% Display the response field.
 Screen('DrawLine', screen.win, par.word_colour,  xCenter - 500, yCenter + 250, ...
    xCenter + 500, yCenter + 250, par.line_width_px);

DrawFormattedText(screen.win, 'Sure New', ...
    confidence_x_ords(1) - 75, yCenter + 350, par.word_colour);
DrawFormattedText(screen.win, 'Sure Old', ...
    xCenter + 450, yCenter + 350, par.word_colour);

% confidence_coords = [140, 140, 390, 390, 640, 640, 890, 890, 1140, 1140;...
%     yCenter + 200, yCenter + 250, yCenter + 200, yCenter + 250, yCenter + 200, yCenter + 250, yCenter + 200, yCenter + 250, yCenter + 200, yCenter + 250];

% Display the confidence segments
confidence_x_ords = linspace(xCenter - 500, xCenter + 500,6);
confidence_x_ords = repelem(confidence_x_ords, 2);
confidence_y_ords = [yCenter + 200, yCenter + 300];
confidence_y_ords = repmat(confidence_y_ords, 1, 6);
confidence_coords = [confidence_x_ords;confidence_y_ords];

Screen('DrawLines',screen.win, confidence_coords, par.word_colour, par.line_width_px);

% Get the initial time with the first flip.
trial_start = Screen('Flip', screen.win);
%% Loops
% Until click, display confidence bar.
not_entered = true;
while not_entered
    
    
    % Display instructions
    DrawFormattedText(screen.win, ['Is this word OLD or NEW?\n\n' 'TEST WORD'], ...
    'center', 'center', par.word_colour);


    % Display the response field.
    Screen('DrawLine', screen.win, par.word_colour,  xCenter - 500, yCenter + 250, ...
        xCenter + 500, yCenter + 250, par.line_width_px);
    DrawFormattedText(screen.win, 'Sure New', ...
        confidence_x_ords(1) - 75, yCenter + 350, par.word_colour);
    DrawFormattedText(screen.win, 'Sure Old', ...
        xCenter + 450, yCenter + 350, par.word_colour);

    % Display the confidence segments
    confidence_x_ords = linspace(xCenter - 500, xCenter + 500,6);
    confidence_x_ords = repelem(confidence_x_ords, 2);
    confidence_y_ords = [yCenter + 200, yCenter + 300];
    confidence_y_ords = repmat(confidence_y_ords, 1, 6);
    confidence_coords = [confidence_x_ords;confidence_y_ords];

    Screen('DrawLines',screen.win, confidence_coords, par.word_colour, par.line_width_px);
    
    % Mouse stuff   
    [mouse_x, ~,mouse_buttons] = GetMouse(screen.win);
    
    
    % We clamp the values at the maximum values of the screen in X and Y
    % incase people have two monitors connected. This is all we want to
    % show for this basic demo.
    mouse_x = min(mouse_x, xCenter + 500);
    mouse_x = max(mouse_x, xCenter - 500);
    

 % Discretise the confidence bar   
    if (confidence_x_ords(1) < mouse_x)&&(mouse_x < confidence_x_ords(3))
        Screen('DrawDots', screen.win, [confidence_x_ords(1) yCenter + 250], 10, par.cursor_colour, [], 2);
    elseif (confidence_x_ords(3) < mouse_x)&&(mouse_x < confidence_x_ords(5))
        Screen('DrawDots', screen.win, [confidence_x_ords(3) yCenter + 250], 10, par.cursor_colour, [], 2);
    elseif (confidence_x_ords(5) < mouse_x)&&(mouse_x < confidence_x_ords(7))
        Screen('DrawDots', screen.win, [confidence_x_ords(5) yCenter + 250], 10, par.cursor_colour, [], 2);
    elseif (confidence_x_ords(7) < mouse_x)&&(mouse_x < confidence_x_ords(9))
        Screen('DrawDots', screen.win, [confidence_x_ords(7) yCenter + 250], 10, par.cursor_colour, [], 2);
    elseif (confidence_x_ords(9) < mouse_x)&&(mouse_x < confidence_x_ords(11))
        Screen('DrawDots', screen.win, [confidence_x_ords(9) yCenter + 250], 10, par.cursor_colour, [], 2);
    else 
        Screen('DrawDots', screen.win, [xCenter + 500 yCenter + 250], 10, par.word_colour, [], 2);
    end
     vbl = Screen('Flip', screen.win);
    
 % Stop when mouse click
     if any(mouse_buttons) 
        not_entered = false;
    end
end

recog_rating = mouse_x;
recog_response_time = vbl - trial_start;




end

