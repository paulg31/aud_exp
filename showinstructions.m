function showinstructions(type,screen)
% Show instructions on screen, wait for keypress to continue

switch type
    
    case 0  % Begin the experiment    
        text = 'Welcome to the Auditory Perception Experiment';
        ypos = 0.4;
    
    case 1  % Counter-Clockwise
        text = 'Tone Discrimination';
        % text = [text '\n\n\n Which target is farther counter-clockwise?'];
        text = [text '\n\n\n\n\n Was the second tone higher or lower?'];
        ypos = 0.25;
       
    case 2 %Break Time
        text = 'Break time';
        ypos = .4;
        
    otherwise
        text = [];
    
end

if ~isempty(text)
    text = [text '\n\n\n\n Press SPACE to continue'];
    
    % Draw all the text
    Screen('TextSize', screen.window, screen.text_size);
    DrawFormattedText(screen.window, text,...
        'center', screen.Ypixels * ypos, screen.white);

    % Flip to the screen
    Screen('Flip', screen.window);

    % Enable only SPACE to continue
    RestrictKeysForKbCheck(32);

    % Wait for key press to move on
    KbWait([],2);
    Screen('Flip', screen.window);

    % Unrestricts Keys
    RestrictKeysForKbCheck([]);
end