function showinstructions(type,screen)
% Show instructions on screen, wait for keypress to continue

switch type
    
    case 0  % Begin the experiment    
        text = 'Welcome to the Auditory Perception Experiment';
        text = [text '\n\n\n\n Press SPACE to continue'];
        restrict = [32];
        ypos = 0.4;
    
    case 1  % Counter-Clockwise
        %text = 'Tone Discrimination Task';
        % text = [text '\n\n\n Which target is farther counter-clockwise?'];
        text = ['\n\n\n\n\n Higher(m), Lower(z), or Not present(b)?'];
        restrict = [90 77 66];
        ypos = 0.25;
       
    case 2 %Break Time
        text = 'Break time';
        ypos = .25;
        restrict = [32];
        
    case 3  %Confidence
        text = 'How confident are you in your response?';
        restrict = [49 50 51 52];
        ypos = 0.25;
        conf = 0;
        
    case 4 %Done
        text = ['You are done'];
        text = [text '\n\n Go get someone'];
        ypos = .25;
        restrict = [27];
    case 5
        text = ['Confidence on next trial?']
        ypos = [.25];
        restrict = [49 50 51 52];
    otherwise
        text = [];
    
end

% if ~isempty(text)
    %text = [text '\n\n\n\n Press SPACE to continue'];
    
    % Draw all the text
    Screen('TextSize', screen.window, screen.text_size);
    DrawFormattedText(screen.window, text,...
        'center', screen.Ypixels * ypos, screen.white);

    % Flip to the screen
    Screen('Flip', screen.window);

    % Enable only SPACE to continue
    RestrictKeysForKbCheck(restrict);

    % Wait for key press to move on
    KbWait;
    % Flip to the screen
    Screen('Flip', screen.window);
    % Unrestricts Keys
    RestrictKeysForKbCheck([]);
end