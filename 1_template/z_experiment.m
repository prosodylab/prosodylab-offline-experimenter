%Purpose: Main method for experiment

close all
clear all

addpath('prosodylabscripts');

%
% ----- Configuration --------------
%
% Experiments of the various experimental sessions:

nExperiments=1;
experiments=[1:nExperiments];

% If you want to run a practice, the practice experiments should be in
% session 1, the others in later sessions.
% If you want more than one experiment in a session, you can specify this
% as a list: session{1}=[1 2 3];
% .

nSessions=1;
session{1} = 1;
instructions{1}='instructions.txt';

session{2} = [1 2 3];
instructions{2}='instructions.txt'; 


% experimentfiles
% these should be a tab-separated files
% only columns that are labeled in the header row will be
% read into a data structure

item_file{1}='polish1010.txt';
item_file{2}='items3.txt';
item_file{3}='items6.txt';
%item_file{4}='items5.txt';

% Design
designs={'Fixed' 'Random' 'PseudoRandom' 'LatinSquare' 'Blocked'};
% decides how the trials will be ordered
% and whether it's latin square or not
% options:
% 1 : Fixed Order (No Randomization):
%     Play all trials in the order of spreadsheet
%     column "condition" and "item" will be ignored
% 2 : Completely random:
%     Play all trials in random order
%     column "condition" and "item" will be ignored
% 3 : Pseudo-random: 
%     Every condition from every item for each participant
%     Items aren't repeated more than once (in fact, a repetition of same 
%     item can only happen once per experiment)
%     Conditions can only be repeated once
%     Number of items has to be divisible by number of conditions
% 4 : Pseudo-random, latin square:
%     Only one condition from each item per subject
%     number of items has to be divisible by number of conditions
%     There will be as many playlists (=groups of participants)
%     as there are conditions
% 5 : Blocked: 
%     Each participant see sonly one conditions.
%     number of items has to be divisible by number of conditions
%     There will be as many playlists (=groups of participants)
%     as there are conditions

design(1)=3;

% Is a file recorded for a given experiment?
% Maybe could be in spreadsheet instead
recordFile(nExperiments)=0;
recordFile(1)=1;

% Other Settings

    % relevant paths (should be given with final '/'
    settings.path_items='1_experiment/';
    settings.path_instructions='1_experiment/';
    settings.path_stimuli='2_stimuli/';
    settings.path_contexts='2_stimuli/';
    settings.path_answers='2_stimuli/';
    settings.path_results='2_data/';
    settings.path_soundfiles='2_data/1_soundfiles/';


    % additional column names
    settings.additionalColNames={'participant','playlist','order','trialN','session'};

    % space between lines in instruction
    settings.linespace=30;
    % fontsize
    settings.textsize = 20;
    % textwidth
    settings.textwidth = 120;

    %
    % Messages to the Participant
    %

    % you can translate these messges in to Korean. Please leave the commented lines in English, 
    % so I know which line is which!

    %settings.message ='Read silently. Press any key when you''re ready for the dialogue.';
    settings.message ='Please read the last line carefully click any key when you''re ready to record!'; 
    settings.message2 ='Please say the last line out loud now. Press any key when you''re done recording!';
    settings.message3 ='Press any key when you''re ready for the next set of instructions!';
    settings.message4 ='Press any key when you''re ready for the next set of instructions!';
    settings.messageShow='Read silently and make sure you understand the sentences.';
    
    %settings.messageThankYou='Thank You!';
    settings.messageThankYou='Thank You!';
    
    settings.messagey=300;
    settings.messagex=20;
    
    settings.contexty=400;
    settings.contextx=50;
    
    settings.texty=600;
    settings.textx=50;
    
    %
    % Audio Settings
    %
   
    %Input device
    % You can check which output devices there are
    % by using the command
    % devices = PsychPortAudio('GetDevices')
    %(unnecessary to worry about if you don't want to record sounds)
    %default outputdevice: use ''
    %(unnecessary to worry about if you don't want to play sounds)
    settings.outputdevice=3;
    settings.inputdevice=1;
    
    settings.sampfreq=22050;
    settings.maxsecs=300;
    settings.voicetrigger=0;
   
    % unify key names across operating systems
    KbName('UnifyKeyNames');

    settings.viewing_interval = 2; % in seconds, so .4 = 400ms
    settings.isi = 1; % inter stimulus interval
 
    settings.before_trial_interval = .5;
    settings.before_prompt_interval = 0;
    settings.trial_time_limit = 300;
    settings.experiment_time_limit = 600;
    settings.num_digits = 2;
    settings.max_addends = 8;
    
    settings.acceptedkeys = {'1!','2@','3#','4$','5%','6^','7&','8*','9(','0)',...
    'RETURN','DELETE','ESCAPE','ENTER','1','2','3','4','5','6','7',...
    '8','9','0'};


% For dialog-experiments, specify the role of the participant
% 0 = participantA; 1=participantB
% role=0;

%
%  -------------------------
%

% clear command window
clc

% Read in Experiment Files and Set Up Result File
for i=1:nExperiments
    
    [items{i},columnNames{i}]=tdfimport([settings.path_items item_file{i}]);
    
    % Set up responses File and Generate Playlist
    responsesFilename{i}=[settings.path_results items{i}(1).experiment '_responses.txt'];
    
    if ~exist(responsesFilename{i})
        
        additionalNames=settings.additionalColNames;
        
        % add columnname for recorded file
        if recordFile(i)
            additionalNames=[ additionalNames,'recordedFile' ];
        end
        
        % add columnnames for participant responses
        if isfield(items{i},'question')
            additionalNames=[additionalNames ,'response', 'correct', 'rt'];
            if isfield(items{i},'question2')
                additionalNames=[ additionalNames ,'response2', 'correct2', 'rt2'];
                if isfield(items{i},'question3')
                    additionalNames=[ additionalNames ,'response3', 'correct3', 'rt3'];
                end
            end
            
        end
        
        % add columnname for end time
        additionalNames = [additionalNames, 'trialDuration','date','trialStart','trialEnd'];
        
        additionalNames=sprintf('%s\t',additionalNames{:});
        
        columnNames{i}=sprintf('%s\t',columnNames{i}{:});
        columnNames{i}=[columnNames{i} additionalNames];
        
        %write column headers to new response file
        fid = fopen(responsesFilename{i},'a','l', 'UTF-8');  %open file and appending
        fprintf(fid,'%s\n',columnNames{i});
        fclose(fid);  %close file
    end
end

% check device numbers for input and output are correct
devices = PsychPortAudio('GetDevices');

findInput=find([devices.DeviceIndex]==settings.inputdevice);
findOutput=find([devices.DeviceIndex]==settings.outputdevice);

disp(' ');
%deviceTable=struct2table(devices);
%disp(deviceTable(:,[1 4]));

disp(' ');
disp('Currently you have selected:');
disp(' ');
disp(['input device:  ' num2str(settings.inputdevice) '     '  devices(findInput).DeviceName]);
disp(['output device:  ' num2str(settings.outputdevice) '     '  devices(findOutput).DeviceName]);
disp(' ');
disp('(you can change this number in the matlab script)');
disp(' ');

while KbCheck(-1); end;
disp('ok?');
while ~KbCheck(-1); end;


[~, ~, keyCode]=KbCheck(-1);

if strcmp('n',KbName(keyCode))
    error('Ok! Please change device numbers in the script!');
end


% Get Participant number
% check whether particpant has already taken part in experiment 1
% if not, detemrine plist number

ok=0;
while ~ok
    participant = input('Please enter the participant number: ', 's');
    
    [participant ok]=str2num(participant);
    if ok
        [pList ok]=checkSetup(participant,design,responsesFilename,nExperiments);
    end
end

%Generate randomized list for participant
[playList, nTrials]=generatePlaylist(items,pList,design,experiments);


for i=1:nExperiments
    disp(['experiment: ' playList{i}(1).experiment ]);
    disp(['design: ' designs{design(i)}]);
    disp(['length: ' num2str(nTrials)]);    
    disp(['item order: ' num2str([playList{i}(:).item ]) ]);
    disp(['condition order: ' num2str([ playList{i}(:).condition ] )]);
end

disp(['type of generated playlist: ']);
if design(1) == 1
    disp(['fixed order']);
elseif design(1) == 2
    disp(['random']);
elseif design(1) == 3
    disp(['pseudo-random']);
elseif design(1) == 4
    disp(['latin square']);
elseif desgin(1) == 5
    disp(['blocked']);
end

while KbCheck(-1); end;
disp('ok?');
while ~KbCheck(-1); end;

[~, ~, keyCode]=KbCheck(-1);

if strcmp('n',KbName(keyCode))
    plistchoice=input('Ok! Please change the design number in the script!', 's');
else
    for i=1:nSessions
        % for each session, run RunExp (this includes a practice run)
        
        %Set up Screen
        ws = doScreen(settings);
        
        % Making sure font settings are correct
        Screen('Preference', 'TextRenderer', 1 );
        Screen('Preference','TextEncodingLocale','UTF-8');
        Screen('TextSize', ws.ptr, settings.textsize);
        
        displayInstructions(ws, [settings.path_instructions instructions{i}], settings);
        RunExp(session{i}, playList, nTrials, pList, participant, recordFile, responsesFilename, settings, i, ws);
        
    end
    
    %Display Thank You Screen
    Screen('TextSize',ws.ptr,60);
    drawText('Thank You!',ws,1);
    
    %ListenChar(0);
end

clear screen
