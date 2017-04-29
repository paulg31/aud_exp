function svname=RunTrial_continuousreport(TrialPars,expWin)
svname='';
SubjName     = TrialPars.SubjName    ;
startKey     = TrialPars.startKey    ;
Tgap         = TrialPars.Tgap        ;
indA         = TrialPars.indA        ;
indB         = TrialPars.indB        ;
DF           = TrialPars.DF          ;
Tdur         = TrialPars.Tdur        ;
PresLength   = TrialPars.PresLength  ;
NumTrips     = TrialPars.NumTrips    ;
svflag       = TrialPars.svflag      ;
svdir        = TrialPars.svdir       ;
Trial        = TrialPars.Trial       ;
NumTrials    = TrialPars.NumTrials   ;
dB           = TrialPars.dB          ;
OveralldBSPL = TrialPars.OveralldBSPL;
fbase        = TrialPars.fbase       ;
tramp        = TrialPars.tramp       ;

% Some remnants of code from our soundbooth; these may be necessary if you
% do not have a mac
% if IsWindows
%     VolumeValue = 1;
%     SoundVolume(VolumeValue);
% end

%% Load tones, build stimuli
% *** In this building stimuli section, you may also find an opportunity to
% add in a manipulation ***

dBGain=OveralldBSPL-dB;
disp(['Volume gain = ',num2str(10^(-dBGain/20))])

% Single-line function to set the volume
set_volume=@(tripunit)tripunit*10^(-dBGain/20);


% This is where the sounds are defined!
toneA = Generate_Pure_Tones(fbase,indA,Tdur,Tgap,tramp);
toneB = Generate_Pure_Tones(fbase,indB,Tdur,Tgap,tramp);
% If you want some deviant tones at a different frequency, make them here

% Pause between triplets is the same length as one tone 
gapz=zeros(size(toneA,1),1);

% Define triplet vectors
tripunit_A=[toneA;gapz;toneA;gapz]'; % A_A_
tripunit_B=[gapz;toneB;gapz;gapz]'; % _B__


tripLength=length(tripunit_A);
tripsequence=zeros(1,tripLength*NumTrips);
% Repeat triplets for NumTrips. If you wanted to alter something about a
% single triplet, would want to do something different on the appropriate
% triplet number (e.g., if ii == 3, do x)
for ii=1:NumTrips
    idx1=(ii-1)*tripLength+1;
    idx2=ii*tripLength;
   tripsequence(1,idx1:idx2)=set_volume(tripunit_A)+set_volume(tripunit_B); 
end

OneStrTrip=tripsequence;

%% Initialise sound
InitializePsychSound(1);
Fs=44100;
KbName('UnifyKeyNames')
pahandle = PsychPortAudio('Open', [], [], 0, Fs, 1);
PsychPortAudio('RunMode', pahandle, 1);

PsychPortAudio('Volume',pahandle,1);
silencio=tripunit_A*0;
PsychPortAudio('FillBuffer',pahandle,silencio);
PsychPortAudio('Start', pahandle, 1, 0,1);
disp('Playing a silent triplet');
PsychPortAudio('Stop', pahandle, 1);

PsychPortAudio('FillBuffer',pahandle,OneStrTrip);

%% Initialise keylogging and data structure
tripflag='One'; 
dispflag='Amb'; % Display flag begins as ambiguous (no response)
keyOneStr='LeftArrow';keyOneCode=KbName(keyOneStr);
keyTwoStr='RightArrow';keyTwoCode=KbName(keyTwoStr);
keyAmbStr='DownArrow';keyAmbCode=KbName(keyAmbStr); % You could choose different keys here

OneStrTimes=[];
TwoStrTimes=[];
AmbStrTimes=[]; % Option for participant to say that stream interpretation is ambiguous

tripletInSecs=Tdur*4/1000;

%% Instruct subject and wait to start

myText=['Response window for subject:\n\n',SubjName,'\n\n',...
    'Trial ',num2str(Trial),' in block of ',num2str(NumTrials),'\n\n',...
    'During task hold:\n\n',...
    'Left for one stream (galloping rhythm)\n\n',...
    'Right for two streams\n\n',...
    'To start trial (after a 2s delay) press ',startKey];
Screen('TextSize',expWin, 24);
Screen('TextFont',expWin,'Helvetica');
DrawFormattedText(expWin, myText, 'center', 'center');
Screen('Flip',expWin); 

% "disp" statements display to MATLAB command window (useful in experiments
% to keep track of subject progress in real-time)
disp(['Waiting for ',startKey,' to start trial']);

% Wait until subject presses start key
while 1
  [keyIsDown, secs, keyCode, deltaSecs] = KbCheck; WaitSecs(0.05);
  if find(keyCode)==KbName(startKey)
      WaitSecs(2.0);break
  end
  % the Escape key will quite the trial and exit in a friendly way
  if ~isempty(find(strncmp('Esc',KbName(keyCode),3),1)) || ~isempty(find(strncmp('ESC',KbName(keyCode),3),1))
      svflag=0;
      try PsychPortAudio('Close', pahandle); disp('closed old');end
      ListenChar;
      Screen('CloseAll');
      error('terminated by user (Esc)');
  end
end

% Set the rate at which to collect keyboard data
KbHz=100;
KbDel=1/KbHz;

% Initialize data structures
TripRegister=zeros(NumTrips+1,1); TripRegister(1)=1;
OnsetTimes=zeros(NumTrips,1);
PreStartTime=GetSecs;

% Start playing the stimulus
StartTime=PsychPortAudio('Start', pahandle, 1, 0,1);

% Redundant to PresLength but in case the division is not equal
StimulusLength=tripletInSecs*NumTrips;
StartTime=GetSecs;

% Interval to display data to Matlab command window
DispTimeInt=0.5;
LastDispTime=StartTime;
% A loop that tracks keypresses while stimulus plays
while GetSecs-StartTime<=StimulusLength
    LoopStartTime=GetSecs;
    [keyIsDown, secs, keyCode, deltaSecs] = KbCheck;
    keyName=KbName(keyCode);
    dispflag='Amb';
    if ~isempty( find(find(keyCode)==keyOneCode,1))
        OneStrTimes=[OneStrTimes;GetSecs-StartTime];
        tripflag='One';
        dispflag=tripflag;
    end
    if ~isempty(find(find(keyCode)==keyTwoCode,1))
        TwoStrTimes=[TwoStrTimes;GetSecs-StartTime];
        tripflag='Two';
        dispflag=tripflag;
    end
    % We're recording the middle key, but we don't use it normally
    if ~isempty(find(find(keyCode)==keyAmbCode,1))
        AmbStrTimes=[AmbStrTimes;GetSecs-StartTime];
        dispflag='Amb';
    end
    % the Escape key will quite the trial and exit in a friendly way
    if ~isempty(find(strncmp('Esc',keyName,3),1)) || ~isempty(find(strncmp('ESC',keyName,3),1))
        svflag=0;
        try PsychPortAudio('Close', pahandle); disp('closed old');end
        ListenChar;
        Screen('CloseAll');
        error('terminated by user (Esc)');
    end
    t1=GetSecs;
    % Display some information every DispTimeInt seconds
    if t1-LastDispTime>DispTimeInt
        LastDispTime=t1;
        disp([dispflag,' t:=',num2str(t1-StartTime,'%.4f'),' [',num2str(StimulusLength-(t1-StartTime),'%.4f'),']  ITI=',...
            num2str(Tdur),'  A=',num2str(indA),' B=',num2str(indB),...
            ' Trial ',num2str(Trial),' of ',num2str(NumTrials)])
    end
    
    % Wait this long before checking keys again
    WaitSecs(KbDel-GetSecs-LoopStartTime);
end

[estStartTime,~,xruns,estStopTime] = PsychPortAudio('Stop',pahandle,1);
if xruns>0
    disp(['Warning ',num2str(xruns),' glitches detected'])
end
disp(['Sound played for ',num2str(estStopTime-estStartTime,'%.6f'),'s']);
EndTime=GetSecs;
PT=EndTime-StartTime;
disp(['Presentation time: ',num2str(PT,'%.6f'),'s']);
disp(['PT Error: ',num2str(1000*(PT-StimulusLength),'%.6f'),'ms']);

try PsychPortAudio('Close', pahandle); disp('closed old');end


%% Write data for trial
svname=['Sub',upper(SubjName),...
    '_dB',num2str(dB),...
    '_ntrips',num2str(NumTrips),...
    '_Tdur',num2str(Tdur),'ms_',...
    'A',num2str(indA),'_',...
    'B',num2str(indB),'_',...
    'DF',num2str(DF)];

datestring=datestr(floor(now));
datestring=strrep(datestring,'-','');
timestring=datestr(rem(now,1),13); % 15 no seconds
timestring=strrep(timestring,':','');
svname=[svname,'_',datestring,'_',timestring];
if svflag
    save([svdir,svname,'.mat'],'OneStrTimes','TwoStrTimes','AmbStrTimes',...
        'TripRegister','SubjName','PresLength',...
        'indA','indB','DF','fbase',...
        'EndTime','StartTime','NumTrips','Tdur','Tgap',...
        'OnsetTimes');
    disp(['Saved to: ']);disp(['''',svname,''';']);
else
    disp(['DATA NOT SAVED!'])
    svname='';
    
    
end