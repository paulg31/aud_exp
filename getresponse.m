function [responsenumber] = getresponse(cond)
% Restricts keys to only use the ones necessary and outputs reaction time

switch cond
    case {'u','d','n'}
     %90 = Z for Down
     %77 = M for Up
     %66 = B for Not Present
     RestrictKeysForKbCheck([90 77 66]);
     
    case {'c'}
     %81 = Q for Low
     %80 = P for High
     RestrictKeysForKbCheck([81 80]);  
     
    case {'confid'}
        RestrictKeysForKbCheck([49 50 51 52]);
end

% Collect keyboard response
secs0 = GetSecs;
KbWait; 
[~, secs, pressedKey, ~] = KbCheck;
responseKey              = find(pressedKey,1);
RT                       = secs-secs0;

% Unrestrict Keys
RestrictKeysForKbCheck([]);

% Convert key numbers to Category or L/R responses
 switch responseKey
     case 90 %Z Presssed for Down
         responsenumber = -1;
     case 77 %M Pressed for Up
         responsenumber = 1;
     case 66 %B Pressed for not Present
         responsenumber = 0;
     case 49
         responsenumber = 1;
     case 50
         responsenumber = 2;
     case 51
         responsenumber = 3;
     case 52
         responsenumber = 4;
 end
        

end