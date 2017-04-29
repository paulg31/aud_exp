function runtrial( screen )
    showinstructions(1,screen);
    WaitSecs(.5);
    
    [correct] = aud_detect();
    correct
end

