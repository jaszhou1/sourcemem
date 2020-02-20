function maths_distractor_old(screen, par, duration, filename)
%MATHS_DISTRACTOR Distractor task between encoding and item recognition
%   Presents 2-digit addition and subtraction problems to the screen until
%   30 seconds have passed. Based on similar code in cogtoolbox (Mike
%   Diaz). Per original, task will not end until the last problem has been
%   completed, so exact time participants spend doing the task will vary.


%% 

%create window with horizontal line

% Draw to the external screen if avaliab  le
screenNumber = max(Screen('Screens'));

white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white/2;

% Open an on screen window
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);

% Query the frame duration
ifi = Screen('GetFlipInterval', window);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Setup the text type for the window
Screen('TextFont', window, 'Ariel');
Screen('TextSize', window, 36);

% Get the centre coordinate of the window
[xCenter, yCenter] = RectCenter(windowRect);

% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 200;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 0 0];
allCoords = [xCoords; yCoords];

% Set the line width for our fixation cross
lineWidthPix = 4;

% % % Draw the line in white, set it to the center of our screen and
% % % set good quality antialiasing
%     lineWin = Screen('DrawLines', window, allCoords,...
%     lineWidthPix, white, [xCenter yCenter], 2);


   

%% Run the Task
FlushEvents('keyDown','mouseDown'); %clears existing input
start = GetSecs;
t1 = start;
while t1-start < 30 %Make this duration and call from parameters
    if true %If people have given a response, generate new numbers to display
    nums = round(rand(1,2)*20)+10;
    end
    
    %I dont know how to preserve the line between flips
    Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);

    % Where the problems go
      Screen('TextSize', window, 72);
    DrawFormattedText(window, num2str(nums(1)), 'center',...
        yCenter * 0.75, white);
    DrawFormattedText(window, num2str(nums(2)), 'center',...
        yCenter * 0.95, white);
    %Display the problem
    t1 = Screen('Flip', window);
   
    %Get Response
    FlushEvents('keyDown', 'mouseDown') %clear keyboard buffer
    str = []; %structure for what people type in

    while true
    s = double(GetChar);

        switch lower(s)
            case cellstr(['0':'9']') %numbers 0-9
            check = 0;
                str = [str char(s)];

                DrawFormattedText(window, str, 'center', yCenter*1.20, white);
                %draw line  
                lineWin = Screen('DrawLines', window, allCoords,...
                lineWidthPix, white, [xCenter yCenter], 2);

                Screen('TextSize', window, 72);
                DrawFormattedText(window, num2str(nums(1)), 'center',...
                yCenter * 0.75, white);
                DrawFormattedText(window, num2str(nums(2)), 'center',...
                yCenter * 0.95, white);
                Screen('Flip', window);

            case {8} %backspace
                if ~isempty(str)
                    str = str(1:end-1);
                    DrawFormattedText(window, str, 'center', yCenter*1.2, white);
                %draw line  
                lineWin = Screen('DrawLines', window, allCoords,...
                lineWidthPix, white, [xCenter yCenter], 2);

                Screen('TextSize', window, 72);
                DrawFormattedText(window, num2str(nums(1)), 'center',...
                yCenter * 0.75, white);
                DrawFormattedText(window, num2str(nums(2)), 'center',...
                yCenter * 0.95, white);

            Screen('Flip', window);
                end
            case {13, 3, 10} %any of the enter keys
                break
        end
    end
    
    %just show line
    Screen('DrawLines', window, allCoords,...
    lineWidthPix, white, [xCenter yCenter], 2);
    Screen('Flip', window);
    
%     %Write out Problem and Response
%     fprintf(mathout, '%d %s %d = %s\r\n', nums(2), nums(1), str);
sca;
end
