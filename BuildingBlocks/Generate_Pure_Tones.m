function [tone]=Generate_Pure_Tones(fbase,foffset,Tdur,Tgap,tramp)
% Generate pure tone, freq in kHz; t in ms
% Code by James Rankin, modified by Pam Osborn Popp (pamop@nyu.edu)
%
% INPUTS:
% fbase - reference frequency 
% foffset - number of semitones desired tone is above fbase
% Tdur - tone duration (e.g. 100ms)
% Tgap - gap at end of tone (e.g. 0ms, no gap)
% tramp - cosine ramp duration (e.g. 10 ms)
%
% OUTPUTS:
% Tones - array of tones column indices correspond to stout values, row
% indices to t values
% t - time vector in ms
% fout - frequency values, indices correspond to stout values
% stout - semitone indices below (-ve)/above (+ve) fbase


% NOTES:
% You can change the necessary inputs if that sound parameter is something
% you wish to modify in your experiment!

if Tgap > Tdur
    error('Gap must be less than tone duration');
end

% This determines the frequency of the tone. We set fbase to middle C, or
% 0.52325 kHz. So if foffset is 0 (e.g., for the 'A' tones), then we have
% fout = 0.52325. If foffset is 5, then fout is 5 semitones above fbase.
% Recall that an octave above is double the frequency and that there are 12
% semitones in an octave.
fout=fbase*2^(foffset/12);

% This code should be similar to things you have seen before
fs = 44.1 % Sampling rate
dt=1/fs;
t=[dt:dt:Tdur]'; % vector of time points

% Handling a possible gap at the end of the tone
if Tgap==0 % If there is no gap at the end of the tone
    tTone=t; % No gap, then tone time vector is just t
    tGap=[]; % No gap
else
    % If there is a gap at the end of your tone, it is included in the
    % total tone duration (e.g., if Tdur is 100ms, and Tgap is 40ms, the
    % tone plays for 60ms and then there is silence for 40ms).
    tToneIdx=find(t>Tdur-Tgap,1); % Finds index of first element of time
                                  % vector t greater than, e.g., 60ms (see above example)
    tTone=t(1:tToneIdx); % Tone plays for first 60ms (for example)
    tGap=t(tToneIdx+1:end); % Gap for last 40ms (for example)
end

% Adding ramps to our tone
rampon = ones(size(tTone));
ramp = sin(0:.5*pi/round(tramp*fs):pi/2).^2';
rampon(1:length(ramp))=ramp;
rampoff = flipud(rampon); % Symmetrical

% Compose tone!
tone=[rampon.*sin(2*pi*fout*tTone).*rampoff;zeros(size(tGap))];

end