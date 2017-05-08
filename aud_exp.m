function aud_exp

subjId = 'spr';
sessionNo = 1;
suffix = 'no1';
familyId = 'a';

block_length = [30 60 20 40];
block_feed = [1 2 1 2];

% Parameter values
sample_rate  = 44100;    % sampling rate (per sec)
sound_dur    = 0.20;     % sound duration, s (200 ms)
pause_dur    = 0.20;      % pause duration, s (200 ms)
ramp_dur     = 0.01;     % ramp duration, s (5-10 ms)
tone_num     = 2;       % number of tones in train
freq         = 440;      % frequency, Hz
sound_amp    = 1;        % sound amplitude, arbitrary units
freq_diff    = 10;       % deviant frequency
dev_prob     = .5;       % probabiltiy of deviant


% %Folders
[currentPath,~,~]   = fileparts(which(mfilename()));
resultsFolder       = [currentPath filesep() 'results' filesep()];
outputFile          = [resultsFolder,'Subj',subjId,'_Session'...
                            num2str(sessionNo) familyId '_data' suffix,'.mat'];    


PsychDefaultSetup(2);

Screen('Preference', 'SkipSyncTests', 2);
screenNumber = max(Screen('Screens'));

%Screen and display info   
screen.width         = 19.7042; %iPad screen width in cm
screen.distance      = 32; % Screen distance in cm
screen.angle         = 2*(180/pi)*(atan((screen.width/2) / screen.distance)) ; % total visual angle of screen in degrees
screen.text_size     = 36;
screen.white         = WhiteIndex(screenNumber);
screen.black         = BlackIndex(screenNumber);
screen.bgcolor       = screen.white / 2;
screen.darkgray      = 10/255;
screen.fixationdur   = 0.5;
screen.ISI           = 0.5;  % Inter-stimulus-interval
screen.betweentrials = 0.3;
screen.feedback_time = 1.1;
screen.sound_volume  = 2;
screen.jitter        = 0.1;  % 10% random jitter of durations
screen.gabor_drift   = 0;    % Gabor drift speed (0=static)
screen.stim_duration = .1; % Stimulus presentation time       

% Correction to stimulus width/period since previously reported dva were off
screen.stimwidthmultiplier = 1.5352;

% Open the screen
[screen.window, screen.windowRect] = PsychImaging('OpenWindow', screenNumber, screen.bgcolor,...
                            [], 32, 2,[], [],  kPsychNeed32BPCFloat);
% Get the size of the on screen window in pixels
[~, screen.Ypixels] = Screen('WindowSize', screen.window);

% Centers
[screen.xCenter, screen.yCenter] = RectCenter(screen.windowRect);

% pixels per degree                        
screen.pxPerDeg     = screen.windowRect(4) / screen.angle; 

% IFI and Screen Info
screen.ifi = Screen('GetFlipInterval', screen.window);
Screen('TextFont', screen.window, 'Times New Roman');
screen = fixcross(screen);

showinstructions(0,screen);
WaitSecs(.5);

for iBlock = 1:numel(block_length)
    data.mat{iBlock}    = [];
end

for iBlock = 1:numel(block_length)
    
    data.block_type{iBlock}     = 'trialz';
        data.fields{iBlock}         = {'trial','dev type','freq diff', 'response','correct','conf'};    

    %Prepare empty data matrix
    if isempty(data.mat{iBlock})
        data.mat{iBlock} =  NaN(block_length(iBlock),numel(data.fields{iBlock})) ; %trial num, item to save nume
    end
    
    num_trials = block_length(iBlock);
    % Begin Loop
    for trial = 1:num_trials
        % Draw fixation cross
        Screen('DrawTexture', screen.window, screen.cross, [], [], 0); 

        % Flip to the screen
        Screen('Flip', screen.window);

        % Deviant sound presence
        if rand(1) <= dev_prob
            dev = 'pres';
        else
            dev = 'abs';
        end

        % Start making sounds params
        switch dev
            case 'pres'
                % Add or subtract freq diif
                if rand(1) <= .5
                    freq_dev = freq + freq_diff;
                    dev_place = 2;
                    cond = 'u';
                    type = 1;
                else
                    freq_dev = freq - freq_diff;
                    dev_place = 2;
                    cond = 'd';
                    type = -1;
                end

            case 'abs'
                % If no deviant tone, deviant is the same as regular freq
                freq_dev = freq;
                dev_place = 2;
                cond = 'n';
                type = 0;
        end

        % Make sounds
        time_vec     = (1:sound_dur*sample_rate)/sample_rate;    % vector of time points
        sound_vec    = sin(2*pi*freq*time_vec);                  % vector of sound waveform
        pnumpts      = round(pause_dur*sample_rate);             % number points in pause
        pause_vec    = zeros(1,pnumpts);                         % pause vector
        sound_vec    = sound_amp*sound_vec/sqrt(mean(sound_vec.*sound_vec)); % normalize sound vector
        sandp        = [sound_vec pause_vec];                    % concatenates s with p
        dev_sound    = sin(2*pi*freq_dev*time_vec);              % vector of deviant sound
        dev_sound    = sound_amp*dev_sound/sqrt(mean(dev_sound.*dev_sound)); %normalized 

        % Make and apply rampon and rampoff
        ramp_on        = min(time_vec/ramp_dur,ones(size(time_vec)));
        ramp_off       = fliplr(ramp_on);
        s_ramp         = ramp_on.*sound_vec.*ramp_off;
        sandp_ramps    = [s_ramp pause_vec]; % concatenates s with p
        dev_sound_ramp = ramp_on.*dev_sound.*ramp_off;
        dev_ramps      = [dev_sound_ramp pause_vec];

        % Train
        train          = zeros(size(sandp_ramps));

            % Construct Sound Train
            for j = 1:dev_place-1
                train = [train sandp_ramps];
            end 

            % Add deviant(or not)
            for j = dev_place
                train = [train dev_ramps];
            end

            % Finish Train
            for j = dev_place+1:tone_num
                train = [train sandp_ramps];
            end

        % Completed Train

        block_type = block_feed(iBlock);
        switch block_type
            case 1
                
                if mod(trial,5) == 0
                    showinstructions(5,screen)
                    [confnumber] = getresponse('confid');
                    sound(train,sample_rate)
                    WaitSecs(1.5);   
                    showinstructions(1,screen);
                    [responsenumber] = getresponse(cond);
                    [correct] = feeback(cond,responsenumber,screen);                     
                    
                else
                    sound(train,sample_rate)
                    WaitSecs(1.5);   
                    showinstructions(1,screen);
                    [responsenumber] = getresponse(cond);
                    showinstructions(3,screen)
                    [confnumber] = getresponse('confid');
                    [correct] = feeback(cond,responsenumber,screen);                     
                end

            case 2
                if mod(trial,5) == 0
                    showinstructions(5,screen)
                    [confnumber] = getresponse('confid');
                    sound(train,sample_rate)
                    WaitSecs(1.5);   
                    showinstructions(1,screen);
                    [responsenumber] = getresponse(cond);
                    [correct] = feeback('confid',responsenumber,screen);
                   % data = cganhe(data,iBlock,num_trials);    
                    WaitSecs(.5);
                else
                    sound(train,sample_rate)
                    WaitSecs(1.5);   
                    showinstructions(1,screen);
                    [responsenumber] = getresponse(cond);
                    showinstructions(3,screen)
                    [confnumber] = getresponse('confid');
                    [correct] = feeback('confid',responsenumber,screen); 
                    %data = cganhe(data,iBlock,num_trials);
                    WaitSecs(.5);
                end

        end

        data.mat{iBlock}(trial,:) = [ ...
                trial, type, freq_diff, responsenumber, correct , confnumber ...
            ];

            % Save data at the end of each trial
            save(outputFile, 'data');
            if mod(trial,2) == 0
                if data.mat{iBlock}(trial,5) == 1 && data.mat{iBlock}(trial-1,5)==1
                    freq_diff = freq_diff - 1;
                    if freq_diff == 0
                        freq_diff = freq_diff+1;
                    end
                elseif data.mat{iBlock}(trial,5) == 0 && data.mat{iBlock}(trial-1,5)== 0
                    freq_diff = freq_diff + 1;
                    if freq_diff == 0
                        freq_diff = freq_diff+1;
                    end
                else
                    freq_diff = freq_diff;
                end
            end
           
end
data = cganhe(data,iBlock,num_trials);
end
showinstructions(4,screen);
save(outputFile, 'data'); 
sca;
end

