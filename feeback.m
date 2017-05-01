function  [] = feeback(cond,responsenumber,screen)
feedbackType = 'text';
line_1 = 'poop';
% Determine what is correct for each block
switch cond 
    case 'u'
        category = 1;
        correct = (category == responsenumber);
        
    case 'd'
        category = -1;
        correct = (category == responsenumber);
            
    case 'n'
        category = 0;
        correct = (category == responsenumber);
end

%Figure out if response was correct
if correct
    feedback_text = '\n\n Correct!';
    text_color = [0 1 0];
else
    feedback_text = '\n\n Incorrect!';
    text_color = [1 0 0];
end

% For the training blocks, display feedback after each trial.
% For the test blocks, do nothing.

switch feedbackType
    case 'text'         
        % Text feedback
        Screen('TextSize', screen.window, screen.text_size);
        DrawFormattedText(screen.window,line_1,...
            'center', 'center', screen.white);
        DrawFormattedText(screen.window,feedback_text,...
            'center', 'center', text_color);
        % Flip to the screen
        Screen('Flip', screen.window);
        WaitSecs(1);

    case 'none'        
        % Do nothing
end
end

