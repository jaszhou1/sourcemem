FlushEvents('keyDown','mouseDown');
KbName('UnifyKeyNames');

not_entered = true;
while not_entered
    [secs, KeyCode, ~] = KbWait();
    
    if KeyCode(11) == 1 
        x = 1;
        not_entered = false;
    elseif KeyCode(12) == 1
        x = 2;
        not_entered = false;
    elseif KeyCode(13) == 1
        x = 3;
        not_entered = false;
    elseif KeyCode(14) == 1
        x = 4;
        not_entered = false;
    elseif KeyCode(15) == 1
        x = 5;
        not_entered = false;
    elseif KeyCode(16) == 1
        x = 6;
        not_entered = false;
    else
        continue
    end
    recog_response_time = secs - trial_start;
    recog_rating = x;
    disp(secs)
    disp(x)
end
 
