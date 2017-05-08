function  [correct] = feeback(cond,responsenumber,screen)
feedbackType = 'text';
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
    case 'confid'
        feedbackType = 'none';
end
if feedbackType ~= 'none'    
    %Figure out if response was correct
    if correct
        feedback_text = ' Correct!';
        text_color = [0 1 0];
    else
        feedback_text = ' Incorrect!';
        text_color = [1 0 0];
    end
else
    correct = NaN;
end

% For the training blocks, display feedback after each trial.
% For the test blocks, do nothing.
if feedbackType ~= 'none'        
        % Text feedback
        Screen('TextSize', screen.window, screen.text_size);
        DrawFormattedText(screen.window,feedback_text,...
            'center', 'center', text_color);
        % Flip to the screen
        Screen('Flip', screen.window);
        WaitSecs(1);
end
end

