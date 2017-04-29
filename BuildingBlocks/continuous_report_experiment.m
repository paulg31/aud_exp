function continuous_report_experiment(SubjectNumber)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% A Simple Psychoacoustic Experiment
%
% Pamela J. Osborn Popp
% pamop@nyu.edu
% March 2017
%
% Function description:
% INPUTS:
%   SubjectNumber : number between 1 and 999; required input (no default)

% TODO:
% - Here, e.g., you can write notes to yourself on updates to make
% - Decide what experimental manipulation you want to use
%
% NOTES:
% - Perhaps your code requires some other functions, scripts, or toolboxes,
% you can note that up here too
% - E.g., requires Psychtoolbox 3, RunTrial_simple, and Generate_Pure_Tones
%
%% Set up working directories

% Handle lack of function inputs
if nargin<1
    error('You must input a subject number.')
end

% For file names
if ismac
    delimiter = '/';
elseif ispc
    delimiter = '\';
end

% Insert your working directory name in here if it will be different from
% your current directory (pwd)
rundir = pwd;
rundir = [rundir,delimiter]; % e.g., '/Users/Documents/'

% Make directory to save data in if it doesn't already exist
data_folder = 'exp_data';
if ~isdir(data_folder)
    mkdir(data_folder);
else
end
addpath(data_folder);
TrialPars.svdir = [rundir,'exp_data',delimiter]; % e.g., '/Users/Documents/exp_data/'

cd(rundir) % Only necessary if it is not already your current directory

% For consistency, we will make all subject numbers in the format "004"
SubjectString=num2str(SubjectNumber);
while length(SubjectString)<3 
    SubjectString=['0',SubjectString];
end


%% Set parameters for experiment 
% When you use this notation, you are creating a "struct," or structure
% array. TrialPars here is the struct containing different "fields" which
% describe different trial parameters. This is a convenient format for
% keeping a lot of variables together under one name so that later we can
% pass TrialPars to the RunTrial function and it receives all these 
% variables (rather than having to pass them individually, which would take
% up many lines of code).

TrialPars.dB           = 65     ;% The volume in dB the sounds will be played at
TrialPars.OveralldBSPL = 95     ;% A calibration number (the loudest dB our setup can generate)
TrialPars.startKey     = 'B'    ;% Key subject will press to begin a trial; here, B for Begin
TrialPars.svflag       = 1      ;% 0 for testing, 1 to save
TrialPars.Trial        = 1      ;% Trial number to be printed to screen (starts at 1)
TrialPars.NumTrials    = 3      ;% Our total number of trials to be printed to screen
TrialPars.fbase        = 0.52325;% in kHz, Middle C / C_5
TrialPars.tramp        = 10     ;% ramp length in ms
TrialPars.DF           = 5      ;% Frequency difference in semitones between A and B
TrialPars.Tdur         = 100    ;% Tone duration
TrialPars.indA         = 0      ;% ABA sequence, A is at fbase
TrialPars.indB         = TrialPars.indA+TrialPars.DF; % B is DF semitones above A
TrialPars.SubjName     = SubjectString; % Subject ID number
TrialPars.Tgap         = 0; % Gap at the end of a tone (here, only gaps between triplets) 
% Number of triplets to play (can specify number of triplets or use
% presentation length and calculate appropriate number of triplets from it)
TrialPars.PresLength   = 10; % Presentation length in s, used to calculate NumTrips
TrialPars.NumTrips     = ceil(TrialPars.PresLength/(4*TrialPars.Tdur/1000));

%% Set up a display window for instructions

% Psychtoolbox keeps track of the different screens (e.g., if you have two
% monitors hooked up to a single computer). Select screen to present on
Screen('Preference','SkipSyncTests', 1); 
screens=Screen('Screens');
Screen('CloseAll');
scrColor=[170,170,170];

% To set psychtoolbox up in a window on your screen:
screenNumber=max(screens); % Selecting which screen to display on
[expWin,rect]=Screen('OpenWindow',screenNumber,scrColor,[10 20 800 600]);
Screen('Preference','SuppressAllWarnings', 1);

% For fullscreen:
% [expWin,rect]=Screen('OpenWindow',screenNumber,scrColor);

% Give Psychtoolbox control of everything, including the keyboard
Priority(1);
ListenChar(2);

%% Run the experiment!
% Try/catch function is there to handle crashes and make sure PsychToolBox 
% shuts down correctly and that we get control of the keyboard/mouse/audio 
% if there's a crash

% Say you want to change the DF with each trial to evaluate the way
% that DF affects the likelihood of perceiving two streams.
DF_values = [7,4,10]; % I know I have three trials so I just chose three values for the example.
% Obviously you would want to have this array saved somewhere so that
% when you analyze the data, you know which trial is which condition.

for ii = 1:TrialPars.NumTrials % Using ii is better than i so you don't overwrite i = sqrt(-1)
    
    % SET PARAMETERS FOR TRIALS
    % Any parameters that change between trials, you should include here
    % For example, if you wish to change fbase between trials, you should 
    % change fbase depending on ii (this could be randomized or completely
    % controlled)
    TrialPars.Trial = ii;
    
    % Since we are changing DF between trials, will need to adjust the
    % trial parameters: 
    TrialPars.DF = DF_values(ii);% Frequency difference in semitones between A and B
    TrialPars.indB = TrialPars.indA+TrialPars.DF; % B is DF semitones above A
    
    % In this example, all the other parameters remain the same across trials.
    
    % RUN THE TRIAL!
    try
        svname=RunTrial_continuousreport(TrialPars,expWin); % Recall expWin is experiment window
        disp(['Data saved to : ',svname]);
    catch ME
        ListenChar(1) % Regain control of the keyboard in case of an exception or error
        try PsychPortAudio('Close'); disp('closed old');end
        ShowCursor;
        Screen('CloseAll');
        rethrow(ME) % Throw MATLAB exception
    end
end

% At the end of the experiment, regain control of the keyboard etc.
ListenChar;
try PsychPortAudio('Close'); disp('closed old');end
Screen('CloseAll');
ShowCursor;

end