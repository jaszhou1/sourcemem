function data = maths_distractor(screen, duration)
%MATHS_DISTRACTOR Distractor task between encoding and item recognition
%   Presents 2-digit addition and subtraction problems to the screen until
%   30 seconds have passed. Based on similar code in cogtoolbox (Mike
%   Diaz). Per original, task will not end until the last problem has been
%   completed, so exact time participants spend doing the task will vary.

% Jason Zhou <jasonz1 AT student DOT unimelb DOT edu DOT au>

data = struct();

% Set the size of the "equation arm" (surely there is another word for this)
fixCrossDimPix = 200;

% Set the line width for the equation line
lineWidthPix = 4;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 0 0];
allCoords = [xCoords; yCoords];

[xCenter, yCenter] = RectCenter(screen.rect);

% Equation line
Screen('DrawLine', screen.win, screen.white,  xCenter - 200, yCenter, ...
    xCenter + 200, yCenter, lineWidthPix);

% Addition sign
DrawFormattedText(screen.win, '+', xCenter - 175,...
    yCenter * 0.95, screen.white);

%% Run the Task
FlushEvents('keyDown','mouseDown'); %clears existing input
start = GetSecs;
trial_start = start;
current_trial = 1;
while trial_start-start < duration %Make this duration and call from parameters
    if true %If people have given a response, generate new numbers to display
        nums = round(rand(1,2)*40 + 40);
    end
    
    %I dont know how to preserve the line between flips
    Screen('DrawLine', screen.win, screen.white,  xCenter - 200, yCenter, ...
        xCenter + 200, yCenter, lineWidthPix);
    DrawFormattedText(screen.win, '+', xCenter - 175,...
        yCenter * 0.95, screen.white);
    
    % Where the problems go
    Screen('TextSize', screen.win, 72);
    DrawFormattedText(screen.win, num2str(nums(1)), 'center',...
        yCenter * 0.75, screen.white);
    DrawFormattedText(screen.win, num2str(nums(2)), 'center',...
        yCenter * 0.95, screen.white);
    %Display the problem
    trial_start = Screen('Flip', screen.win);
    
    %Get Response
    FlushEvents('keyDown', 'mouseDown') %clear keyboard buffer
    str = []; %structure for what people type in
    
    while true
        s = double(GetChar);
        
        switch lower(s)
            case cellstr(['0':'9']') %numbers 0-9
                check = 0;
                str = [str char(s)];
                
                DrawFormattedText(screen.win, str, 'center', yCenter*1.20, screen.white);
                %draw line
                Screen('DrawLine', screen.win, screen.white,  xCenter - 200, yCenter, ...
                    xCenter + 200, yCenter, lineWidthPix);
                DrawFormattedText(screen.win, '+', xCenter - 175,...
                    yCenter * 0.95, screen.white);
                Screen('TextSize', screen.win, 72);
                DrawFormattedText(screen.win, num2str(nums(1)), 'center',...
                    yCenter * 0.75, screen.white);
                DrawFormattedText(screen.win, num2str(nums(2)), 'center',...
                    yCenter * 0.95, screen.white);
                Screen('Flip', screen.win);
                
                
            case {8} %backspace
                if ~isempty(str)
                    str = str(1:end-1);
                    DrawFormattedText(screen.win, str, 'center', yCenter*1.2, screen.white);
                    %draw line
                    Screen('DrawLine', screen.win, screen.white,  xCenter - 200, yCenter, ...
                        xCenter + 200, yCenter, lineWidthPix);
                    DrawFormattedText(screen.win, '+', xCenter - 175,...
                        yCenter * 0.95, screen.white);
                    
                    
                    Screen('TextSize', screen.win, 72);
                    DrawFormattedText(screen.win, num2str(nums(1)), 'center',...
                        yCenter * 0.75, screen.white);
                    DrawFormattedText(screen.win, num2str(nums(2)), 'center',...
                        yCenter * 0.95, screen.white);
                    
                    Screen('Flip', screen.win);
                end
            case {13, 3, 10} %any of the enter keys
                vbl = Screen('Flip', screen.win);  %Trying to get the time at finish
                response_time = vbl - trial_start;
                break
        end
    end
    
    %The problem right now is that it is only saving the last trial- the last
    %equation and solution. I need it to remember all of them, like it does for
    %the blocks outside, but it says "Number of fields in structure arrays being concatenated do not match. Concatenation of structure arrays requires
    %that these arrays have the same set of fields."
    
    %Write out Problem and Response
    data(current_trial).num1 = nums(1);    %what people saw
    data(current_trial).num2 = nums(2);
    data(current_trial).resp = str;        %what people typed in
    data(current_trial).rt = response_time;
    current_trial = current_trial + 1;
    
end
end
