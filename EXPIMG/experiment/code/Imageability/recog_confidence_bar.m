function [ recog_rating, recog_response_time ] = ... 
    recog_confidence(screen, par,word)
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

% Get the size of the on screen window
[screenXpixels, ~] = Screen('WindowSize', screen.win); %don't care about y

%% Initial display

%Display instructions

DrawFormattedText(screen.win, ['Is this word OLD or NEW?\n\n' word], ...
    'center', 'center', par.word_colour);

% Display the response field.
 Screen('DrawLine', screen.win, par.word_colour,  xCenter - 500, yCenter + 250, ...
    xCenter + 500, yCenter + 250, par.line_width_px);

% Display the confidence segments
confidence_x_ords = linspace(xCenter - 500, xCenter + 500,6);
confidence_x_ords = repelem(confidence_x_ords, 2);
confidence_y_ords = [yCenter + 200, yCenter + 300];
confidence_y_ords = repmat(confidence_y_ords, 1, 6);
confidence_coords = [confidence_x_ords;confidence_y_ords];

DrawFormattedText(screen.win, 'Sure New', ...
    confidence_x_ords(1) - 75, yCenter + 350, par.word_colour);
DrawFormattedText(screen.win, 'Sure Old', ...
    xCenter + 425, yCenter + 350, par.word_colour);

% confidence_coords = [140, 140, 390, 390, 640, 640, 890, 890, 1140, 1140;...
%     yCenter + 200, yCenter + 250, yCenter + 200, yCenter + 250, yCenter + 200, yCenter + 250, yCenter + 200, yCenter + 250, yCenter + 200, yCenter + 250];

Screen('DrawLines',screen.win, confidence_coords, par.line_width_px, par.word_colour);

% Get the initial time with the first flip.
trial_start = Screen('Flip', screen.win);
%% Loops
% Until click, display confidence bar.
not_entered = true;
while not_entered
    
    
    % Display instructions
    DrawFormattedText(screen.win, ['Is this word OLD or NEW?\n\n' word], ...
    'center', 'center', par.word_colour);


    % Display the response field.
    Screen('DrawLine', screen.win, par.word_colour,  xCenter - 500, yCenter + 250, ...
        xCenter + 500, yCenter + 250, par.line_width_px);
    DrawFormattedText(screen.win, 'Sure New', ...
        confidence_x_ords(1) - 75, yCenter + 350, par.word_colour);
    DrawFormattedText(screen.win, 'Sure Old', ...
        xCenter + 425, yCenter + 350, par.word_colour);

    % Display the confidence segments
    confidence_x_ords = linspace(xCenter - 500, xCenter + 500,6);
    confidence_x_ords = repelem(confidence_x_ords, 2);
    confidence_y_ords = [yCenter + 200, yCenter + 300];
    confidence_y_ords = repmat(confidence_y_ords, 1, 6);
    confidence_coords = [confidence_x_ords;confidence_y_ords];

    Screen('DrawLines',screen.win, confidence_coords, par.line_width_px, par.word_colour);
    
 % Mouse stuff   
    [mouse_x, ~,mouse_buttons] = GetMouse(screen.win);
    % Clamp the mouse values at the maximum values of the screen in X 
    % incase people have two monitors connected.
    mouse_x = min(mouse_x, screenXpixels);
    
 % Discretise the confidence bar   
    if mouse_x < confidence_x_ords(3)
        Screen('DrawDots', screen.win, [confidence_x_ords(1) yCenter + 250], 10, par.cursor_colour, [], 2);
    elseif (confidence_x_ords(3) < mouse_x)&&(mouse_x < confidence_x_ords(5))
        Screen('DrawDots', screen.win, [confidence_x_ords(3) yCenter + 250], 10, par.cursor_colour, [], 2);
    elseif (confidence_x_ords(5) < mouse_x)&&(mouse_x < confidence_x_ords(7))
        Screen('DrawDots', screen.win, [confidence_x_ords(5) yCenter + 250], 10, par.cursor_colour, [], 2);
    elseif (confidence_x_ords(7) < mouse_x)&&(mouse_x < confidence_x_ords(9))
        Screen('DrawDots', screen.win, [confidence_x_ords(7) yCenter + 250], 10, par.cursor_colour, [], 2);
    elseif (confidence_x_ords(9) < mouse_x)&&(mouse_x < confidence_x_ords(11))
        Screen('DrawDots', screen.win, [confidence_x_ords(9) yCenter + 250], 10, par.cursor_colour, [], 2);
    elseif mouse_x > confidence_x_ords(11)
        Screen('DrawDots', screen.win, [confidence_x_ords(11) yCenter + 250], 10, par.cursor_colour, [], 2);
    end
        vbl = Screen('Flip', screen.win);
    
 % Stop when mouse click
     if any(mouse_buttons) 
        not_entered = false;
    end
end

% convert position to rating output

    if mouse_x < confidence_x_ords(3)
        mouse_x_rate = 1;
    elseif (confidence_x_ords(3) < mouse_x)&&(mouse_x < confidence_x_ords(5))
        mouse_x_rate = 2;
    elseif (confidence_x_ords(5) < mouse_x)&&(mouse_x < confidence_x_ords(7))
        mouse_x_rate = 3;
    elseif (confidence_x_ords(7) < mouse_x)&&(mouse_x < confidence_x_ords(9))
        mouse_x_rate = 4;
    elseif (confidence_x_ords(9) < mouse_x)&&(mouse_x < confidence_x_ords(11))
        mouse_x_rate = 5;
    elseif mouse_x > confidence_x_ords(11) 
        mouse_x_rate = 6;
    else
        mouse_x_rate = 0; %sometimes the mouse_x seems to break, this is so I can see when
    end

recog_rating = mouse_x_rate;
recog_response_time = vbl - trial_start;

end

