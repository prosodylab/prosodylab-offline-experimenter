% Main experiment method

commandwindow

close all
clear all

clc

% item file (should be a tab-separated files, encoded in UTF-8)
% only columns that are labeled in the header row will be read into a data structure

itemFile='msvt.txt';

%Input and Output device (your present choice is displayed when you run
%script.
% You can also check which output devices there are
% by using the command devices = PsychPortAudio('GetDevices')
% (unnecessary to worry about if you don't want to record sounds)
% default outputdevice: use ''
% (unnecessary to worry about if you don't want to play sounds)

% settings for mac mini with USB: both should be '1'
% settings for mac laptop: usually '0' for input, '1' for default output

settings.outputdevice=1;
settings.inputdevice=0;

% Design: Needs to be specified in column 'design' in experiment spreadsheet
% Options:
%
designs={'Between' 'Blocked' 'BlockedFixed' 'Fixed'  'LatinSquare' 'Random' 'Within'};
%
%
% Between
%     Each participant sees only one condition.
%     Mumber of items has to be divisible by number of conditions
%     There will be as many playlists (=groups of participants)
%     as there are conditions
% Blocked:
%     Each participant see all conditions.
%     There will be a separate block for every condition.
%     Blocks are in random order.
%     There will be as many playlists (=groups of participants)
%     as there are conditions, which will reflect which condition was run
%     in the first block
% BlockedFixed:
%     Each participant see all conditions.
%     There will be a separate block for every condition.
%     Blocks are in fixed order (condition 1 first), order within is random.
%     Number of items has to be divisible by number of conditions
% Fixed (Fixed Order; No Randomization):
%     Play all trials in the order of spreadsheet
%     column "condition" and "item" will be ignored
% LatinSquare:
%     Only one condition from each item per subject
%     Equal number of trials from each condition.
%     Number of items has to be divisible by number of conditions.
%     Order is pseudo-random, conditions can only be repeated once.
%     There will be as many playlists (=groups of participants)
%     as there are conditions
% Random (completely random):
%     Play all trials in completely random order
%     column "condition" and "item" will be ignored
% Within:
%     Everyone see all conditison from all items.
%     Trials are randomized in blocks, such that each block corresponds
%     to a latin square set up (one condition from each item, equal number
%     from each condition). 
%     Order within block is pseudo-random, conditions can only be repeated once.
%     order of blocks are randomized. 
%     Number of items has to be divisible by number of conditions
%     First item=n/nCondition trials can be analyzed as latin square design
%     experiment.
%     Items aren't repeated more than once at transitions between blocks.
%     Conditions can only be repeated once.
%     Number of items has to be divisible by number of conditions

% Settings

% randomize order of experiments within a session, if there are multiple
% ones
randomizeOrderExperiments=true;

% relevant paths (should be given with final '/'
settings.path_items='1_experiment/';
settings.path_instructions='1_experiment/';
settings.path_stimuli='2_stimuli/';
settings.path_contexts='2_contexts/';
settings.path_answers='2_answers/';
settings.path_results='2_data/';
settings.path_soundfiles='2_data/1_soundfiles/';
settings.path_images='2_images/';

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
settings.message ='Please read the sentence silently. Click any key when you''re ready to record!';
settings.message2 ='Please say the sentence out loud now. Press any key when you''re done recording!';
settings.message3 ='Press any key when you''re ready for the next trial!';
settings.message4 ='Press any key when you''re ready for the next sentence!';
settings.message5 ='Now say the same sentence, but faster!';
settings.retrialMessage ='Do you want to rerecord (y/n)?';
settings.retrialMessage2 ='Ok! Press a key when you''ready to repeat the trial!';

%settings.messageThankYou='Thank You!';
settings.messageThankYou='Thank You!';

settings.messagey=300;
settings.messagex=20;

settings.contexty=400;
settings.contextx=50;

settings.texty=600;
settings.textx=50;

% additional column names
settings.additionalColNames={'participant','playlist','experimentTrial','sessionTrial'};


%
% Other Audio Settings
%

settings.samplingFrequency=22050;
settings.maxsecs=300;
settings.voiceTrigger=0.05;
settings.paceDelay=1; % in seconds

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


addpath('prosodylabscripts');

% check device numbers for input and output are correct
devices = PsychPortAudio('GetDevices');

findInput=find([devices.DeviceIndex]==settings.inputdevice);
findOutput=find([devices.DeviceIndex]==settings.outputdevice);

disp(' ');
deviceTable=struct2table(devices);
disp(deviceTable(:,[1 4]));

disp(' ');
disp('Currently you have selected:');
disp(' ');
disp(['input device:  ' num2str(settings.inputdevice) '     '  devices(findInput).DeviceName]);
disp(['output device:  ' num2str(settings.outputdevice) '     '  devices(findOutput).DeviceName]);
disp(' ');
disp('(you can change this number on line 132-133 in code)');
disp(' ');

while KbCheck(-1); end;
disp('ok?');
disp(' ');
while ~KbCheck(-1); end;

[~, ~, keyCode]=KbCheck(-1);

if strcmp('n',KbName(keyCode))
    error('Ok! Please change device numbers in the script!');
end


%
%  -------------------------
%

% Read in items and set up experiments and sessions

[allItems,columnNames]=tdfimport([settings.path_items itemFile]);

experimentNames=unique({ allItems.experiment });
nExperiments=length(experimentNames);
[items{1:nExperiments}]=deal([]);


% add session column if there is none
if ~isfield(allItems, 'session')
    [allItems.session]=deal(1);
    columnNames= [columnNames,'session']; 
end

% add default instructions file name if there isn't one specified
if ~isfield(allItems, 'instructions')
    [allItems.instructions]=deal('instructions.txt');
    columnNames= [columnNames,'instructions']; 
end
% set up sessions
nSessions=max([allItems.session]);
[sessions{1:nSessions}]=deal([]);
[instructions{1:nSessions}]=deal([]);

% randomize order of experiments within a session
if randomizeOrderExperiments
    exOrder=randperm(nExperiments);
else
    exOrder=1:nExperiments;
end

% assign experiments to session
for i=1:nExperiments
    
    % create spreadsheet for each experiment
    items{exOrder(i)}=allItems(strcmp({allItems.experiment},experimentNames(exOrder(i))));
    
    
    % add experiment to session
    eSession=unique([items{exOrder(i)}.session]);
    if length(eSession)>1
        error(['Experiment ' experimentNames(exOrder(i)) ' has more than one session specified'])
    end
    sessions{eSession}=[sessions{eSession} exOrder(i)];
end


for i=1:nSessions
    allSession=allItems([allItems.session]==i);
    if length(unique({allSession.instructions}))>1
        error(['Session ' num2str(i) ' has more than one set of instructions specified.'])
    elseif isempty(unique({allSession.instructions}))
        error(['Session' num2str(i) ' has no instructions specified'])
    end
    instructions(i)=unique({allSession.instructions});
end


% Set up responses File and Generate Playlists

responsesFilename=[settings.path_results strjoin(experimentNames,'_') '_responses.txt'];

if ~exist(responsesFilename,'file')
    
    additionalNames=settings.additionalColNames;
    
    % add columnname for recorded file
    if isfield(items{i},'record')
        if max(ismember({'Yes','y','yes','YES','memorized','Memorized'},unique({items{i}(:).record})))==1
            additionalNames=[ additionalNames,'recordedFile' ];
        elseif max(ismember({'twice','Twice'},unique({items{i}(:).record})))==1
            additionalNames=[ additionalNames,'recordedFile','secondRecordFile' ];
        elseif max(ismember({'paced','Paced'},unique({items{i}(:).record})))==1
            additionalNames=[ additionalNames,'timeToTrigger','recordedFile' ];
        end
    end
    
    % add columnnames for participant responses for each question
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
    
    columnNames=strjoin(columnNames,'\t');
    columnNames=strjoin({columnNames,additionalNames},'\t');
    
    %write column headers to new response file
    fid = fopen(responsesFilename,'a','l', 'UTF-8');  %open file and appending
    fprintf(fid,'%s\n',columnNames);
    fclose(fid);  %close file
end


% Get Participant number
% check whether particpant has already taken part in any of the experiments
% and determine plist number participant should be run on

ok=0;
while ~ok
    participant = input('Please enter the participant number: ', 's');
    
    [participant, ok]=str2num(participant);
    if ok
        [pList, ok]=checkSetup(participant,responsesFilename,experimentNames,items);
    end
end

%Generate randomized list for participant
[playList, nTrials]=generatePlaylist(items,pList,experimentNames);


% output design of experiment for confirmation
for i=1:nSessions
    
    disp(' ');
    disp(['Session: ' num2str(i)]);
    disp(' ');
    
    for j=1:length(sessions{i})
        exper=sessions{i}(j);
        
        disp(' ');
        disp(['Experiment: ' playList{exper}(1).experiment ]);
        disp(['Design: ' playList{exper}(1).design [' Playlist: ' num2str(pList(exper))] ]);
        disp(['Length: ' num2str(nTrials(exper)) ' Number Items: ' num2str(max([playList{exper}(:).item ])) ' Number Conditions: ' num2str(max([playList{exper}(:).condition ]))]);
        disp('');
        disp(['item order: ' num2str([playList{exper}(:).item ]) ]);
        disp(['condition order: ' num2str([ playList{exper}(:).condition ]) ]);
        disp('');
        
        
        if isfield(playList{exper}(1),'contextFile')
             existingContextFiles=extractfield(dir([settings.path_contexts]),'name');
             contextFiles=extractfield(playList{exper}(:),'contextFile');
             if min(ismember(contextFiles,existingContextFiles))==0
                disp('Not all context files found in folder');
                disp('');
                disp(['Missing files:' contextFiles(~ismember(contextFiles,existingContextFiles)) ]);
                 error(['Add missing context files or fix name! (Path: ' settings.path_contexts ')']);
             end
         end
         
         if isfield(playList{exper}(1),'answerFile')
             existingAnswerFiles=extractfield(dir([settings.path_answers]),'name');
             answerFiles=extractfield(playList{exper}(:),'answerFile');
             if min(ismember(answerFiles,existingAnswerFiles))==0
                disp('Not all answer files found in folder');
                disp('');
                disp(['Missing files:' answerFiles(~ismember(answerFiles,existingContextFiles)) ]);
                error(['Add missing context files or fix name! (Path: ' settings.path_answers ')']);
             end
         end
        
        %
        
    end
    
    while KbCheck(-1); end;
    disp('ok?');
    while ~KbCheck(-1); end;
    
    [~, ~, keyCode]=KbCheck(-1);
    
    if strcmp('n',KbName(keyCode))
        error('Ok! Please change the set up in the script!');
    end
    
end


%Set up Screen
ws = doScreen(settings);


% Run Experiment
for i=1:nSessions
    % for each session, run RunExp
    
    % Making sure font settings are correct
    Screen('Preference', 'TextRenderer', 1 );
    Screen('Preference','TextEncodingLocale','UTF-8');
    Screen('TextSize', ws.ptr, settings.textsize);
    
    displayInstructions(ws, [settings.path_instructions instructions{i}], settings);
    RunSession(i,sessions{i}, playList, nTrials, pList, participant, responsesFilename, settings, ws);
    
end

%Display Thank You Screen
Screen('TextSize',ws.ptr,60);
drawText('Thank You!',ws,1);

clear screen
