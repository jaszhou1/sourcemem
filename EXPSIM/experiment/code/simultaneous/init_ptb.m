function screen = init_ptb(screen_number, background_number, debug_mode) 
%INIT_PTB A general-purpose function for initialising Psychtoolbox.
%   Initialises Psychtoolbox, either with a number of control inputs, or
%   with sensible defaults. This function then returns a structure that can
%   be used by many of my other drawing functions (bundling together all of
%   the relevant state).
%
% Simon Lilburn <lilburns AT unimelb DOT edu DOT au>

screen = struct();

% Assert that OpenGL is operational on this system.
AssertOpenGL;

% If necessary, enter into Psychtoolbox's debugging mode.
if debug_mode
    PsychDebugWindowConfiguration();
end

% If the string 'max' or 'min' are in the screen number argument, replace
% with the actual screen number.
if screen_number == 'min' 
    screen_number = min(Screen('Screens'));
end
if screen_number == 'max' 
    screen_number = max(Screen('Screens'));
end

% Initialise Psychtoolbox.
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
[win, win_rect] = PsychImaging('OpenWindow', screen_number, ...
    background_number);
screen.win = win;
screen.rect = win_rect;

% Turn the cursor off.
HideCursor();

% Get the interflip interval.
screen.ifi = Screen('GetFlipInterval', win);

% The index of white and the index of black.
screen.white = WhiteIndex(win);
screen.black = BlackIndex(win);

% Get the centre of the screen.
[centre_x, centre_y] = RectCenter(screen.rect);
screen.centre = [centre_x, centre_y]; 

% Function for calculating rectangles from centre of screen.
screen.centre_fn = @(height, width) ([screen.centre(1) - width/2, ...
    screen.centre(2) - height/2, screen.centre(1) + width/2, ...
    screen.centre(2) + height/2]);
screen.rect_fn = @(x, y, height, width) ([x - width/2, ...
    y - height/2, x + width/2, y + height/2]);

% Do an initial flip and get the first time stamp.
screen.start_time = Screen('Flip', win);

end
