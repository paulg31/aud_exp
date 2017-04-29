function [DD,data] = DevDetectIO_PJG(num_tones,deviant_freq,num_trials,prob_dev)

% Parameter values
sample_rate  = 44100;    % sampling rate (per sec)
sound_dur    = 0.25;     % sound duration, s
pause_dur    = 0.1;      % pause duration, s
ramp_dur     = 0.01;     % ramp duration, s (5-10 ms is reasonable)
tone_num     = num_tones;       % number of tones in train
freq         = 600;      % frequency, Hz
sound_amp    = 1;        % sound amplitude, arbitrary units
freq_diff    = deviant_freq;       % deviant frequency
dev_prob     = prob_dev;       % probabiltiy of deviant

% Ask for number of trials
trial_num = num_trials;
DD = zeros(3,2);

% Begin Loop
for trial = 1:trial_num
    correct      = 0;        % counting num correct
    wrong        = 0;        % counting num wrong
    
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
            else
                freq_dev = freq - freq_diff;
            end

            % Set Position of deviant
            if rand(1) <= .5
                dev_place = 2;
                position = 'e';
                DD(1,1)     = DD(1,1) +1;
                pos = 1;
            else
                dev_place = tone_num;
                position = 'l';
                DD(2,1)     = DD(2,1) +1;
                pos = 2;
            end
            
        case 'abs'
            % If no deviant tone, deviant is the same as regular freq
            freq_dev = freq;
            dev_place = tone_num;
            position = 'n';
            DD(3,1)     = DD(3,1) +1;
            pos = 3;
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
    WaitSecs(3);
    resp = input('Was the deviant tone (e)arly, (l)ate, or (n)ot present? ','s');
    
    %Responses
    if resp == position
        'correct'
        DD(pos,2) = DD(pos,2) + 1;
    else
        'try again'
    end
end
bar([1:3],DD)
xlabel('trial type')
legend('#trials','#correct')
end