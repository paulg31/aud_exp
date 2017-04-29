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


% Ask for number of trials
trial_num    = input('Trial number = ');
correct      = 0;        % counting num correct
wrong        = 0;        % counting num wrong

% Begin Loop
for trial = 1:trial_num

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
            else
                freq_dev = freq - freq_diff;
                dev_place = 2;
                cond = 'd';
            end
            
        case 'abs'
            % If no deviant tone, deviant is the same as regular freq
            freq_dev = freq;
            dev_place = 2;
            cond = 'n';
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
    sound(train,sample_rate)
    
    %Wait before displaying question
    WaitSecs(1.5);
    resp = input('Was the deviant tone (u)p, (d)own, or (n)ot present? ','s');
    
    %Responses
    if resp == cond
        'correct'
        correct = correct + 1;
    else 
        'try again'
        wrong = wrong +1;
    end
    
end