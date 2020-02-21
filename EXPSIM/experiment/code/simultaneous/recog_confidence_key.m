function [ recog_rating, recog_response_time ] = ...
    recog_confidence_key(screen, par,word)
%RECOG_CONFIDENCE_KEY. A six-point Old/New judgement for items in previously
%encoded word lists. In this version, people just type the corresponding key 
%on the keyboard. Equal number of target items and lures. 
%Used to obtain recognition confidence ratings that we can condition source responses on.
% Jason Zhou <jasonz1 AT student DOT unimelb DOT edu DOT au>
%% Definitions 
% Unify Key Names for portability
KbName('UnifyKeyNames');

% Define Center
%[xCenter, yCenter] = RectCenter(screen.rect);

% Word size and font
Screen('TextSize', screen.win, par.word_size_px);
Screen('TextFont', screen.win, par.font_name);

%% Initial display

%Display instructions

DrawFormattedText(screen.win, ['Is this word NEW or OLD?\n\n\n' word ...
    '\n\n\nPlease Enter a number from 1 (Sure NEW) to 6 (Sure OLD)'],...
    'center', 'center', par.word_colour);

% Get the initial time with the first flip.
trial_start = Screen('Flip', screen.win);
%% Loops
% Until click, display confidence input field
%%
FlushEvents('keyDown','mouseDown'); %clears existing input
%RestrictKeysForKbCheck([49:54, 8, 13, 3, 10]); Simon says not to restrict
%keys
while true
    [secs, KeyCode, ~] = KbWait();
    DrawFormattedText(screen.win, ['Is this word NEW or OLD?\n\n\n' word ...
        '\n\n\nPlease Enter a number from 1 (Sure NEW) to 6 (Sure OLD)'],...
        'center', 'center', par.word_colour);
    
    % Using KbName gave me 1! and 2@- didn't know how to get around this, so
    % this is just something that should work until I figure out something
    % better.
    if KeyCode(11) == 1 % keys 1 to 6 (below the function keys)
        x = 1;
    elseif KeyCode(12) == 1
        x = 2;
    elseif KeyCode(13) == 1
        x = 3;
    elseif KeyCode(14) == 1
        x = 4;
    elseif KeyCode(15) == 1
        x = 5;
    elseif KeyCode(16) == 1
        x = 6;
    else
        continue
    end
    recog_response_time = secs - trial_start;
    recog_rating = x;
    break
end
