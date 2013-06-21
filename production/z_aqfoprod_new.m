
%Purpose: Main method for experiment
% chael@mcgill.ca 11/17/09

close all
clear all

addpath('prosodylabscripts');

%
% ----- Configuration --------------
%
% Choose number of experiments:

nExperiments = 1;
experiments=1:nExperiments;
[~, nexp]=size(experiments);

practice=0;

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

% Number of questions a participant is maximially asked
nQuestions(1)=0;

% Is a file recorded?
recordedFile(nExperiments)=0;
recordFile(1)=1;
%recordFile(2)=1;

% experimentfiles
% these should be a tab-separated files
% only columns that are labeled in the header row will be
% read into a data structure

%item_file{1}='scram.txt';
item_file{1}='aqfoprod_new.txt';


% relevant paths (should be given with final '/'
path_items='1_experiment/';
path_instructions='1_experiment/';
path_stimuli='2_stimuli/';
path_results='2_data/';
path_soundfiles='2_data/1_soundfiles/';

%Load Experiment Settings
% are these currently used for anything?
[settings]=z_settings();

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
    
    [items{i},columnNames{i}]=tdfimport([path_items item_file{i}]);
    
    % Set up responses File and Generate Playlist
    responsesFilename{i}=[path_results items{i}(1).experiment '_responses.txt'];
    
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
        additionalNames=sprintf('%s\t',additionalNames{:});
        
        columnNames{i}=sprintf('%s\t',columnNames{i}{:});
        columnNames{i}=[columnNames{i} additionalNames];
        
        %write column headers to new response file
        fid = fopen(responsesFilename{i},'a','l', 'UTF-8');  %open file and appending
        fprintf(fid,'%s\n',columnNames{i});
        fclose(fid);  %close file
    end
end

% Get Participant number
% check whether particpant has already taken part in experiment 1
% if not, detemrine plist number

ok=0;
while ~ok
    participant = input('Please enter the participant number: ', 's');
    [participant ok]=str2num(participant);
    participant_language = input('What is the participants first language? ', 's');
    if ok
        [pList ok]=checkSetup(participant,design,responsesFilename,nExperiments);
    end
end

%Generate randomized list for participant
[playList, nTrials]=generatePlaylist(items,pList,design,experiments);

for i=1:nexp
    disp(['experiment: ' playList{i}(1).experiment ]);
    disp(['design: ' designs{design(i)}]);
    disp(['length: ' num2str(nTrials)]);    
    disp(['item order: ' num2str([playList{i}(:).item ]) ]);
    disp(['condition order: ' num2str([ playList{i}(:).condition ] )]);
end

while KbCheck(-1); end;
disp('ok?');
while ~KbCheck(-1); end;

[~, ~, keyCode]=KbCheck(-1);

if strcmp('n',KbName(keyCode))
    plistchoice=input('Ok! Please change the design number in the script!', 's');
else



%Display Screen
ws = doScreen(settings);
%ListenChar(2);

displayInstructions(ws, [ path_instructions 'instructions.txt'],settings);

%
%
% Practice Session
%
%

if practice==1
    [itemsPractice{1},columnsPractice]=tdfimport([ path_items itemFilePractice]);
    responsesPractice=[path_results itemsPractice{1}(1).experiment '_responses.txt'];
    
    if ~exist(responsesPractice)
        
        % add columnnames for participant responses
        additionalNames= additionalColNames;
        additionalNames=sprintf('%s\t',additionalNames{:});
        
        columnsPractice=sprintf('%s\t ',columnsPractice{:});
        columnsPractice=[columnsPractice additionalNames];
        
        %write column headers to new response file
        fid = fopen(responsesPractice,'a','l', 'UTF-8');  %open file and appending
        fprintf(fid,'%s\n',columnsPractice);
        fclose(fid);  %close file
    end
    
    pListPractice(1)=0;
    
    experiments=[ 1 ];
    
    [playListPractice nPractice] = generatePlaylist(itemsPractice,pListPractice,experiments);
    
    
    counter=0;
    while nPractice-counter ~=0
        
        if counter ~= 0
            askReady(ws,double(settings.message3),settings);
        end
        
        counter=counter+1;
        k=counter;
        i=1;
        
        % add information about participant
        playListPractice{i}(k).participant=participant;
        playListPractice{i}(k).playlist=pListPractice(i);
        playListPractice{i}(k).order=counter;
        playListPractice{i}(k).nTrial=counter;
        
        %1-Display sentence to user
        
        %dialogue=[playListPractice{i}(k).context '\n\n' playListPractice{i}(k).text];
        text=playListPractice{i}(k).text;
        context=playListPractice{i}(k).context;
        % displayTextKey(ws,text);
        
        %3-Record Sentence
        % should eventually convert .lab text into right format right off
        %Construct wave file name
        wavfilename=[playListPractice{i}(k).experiment '_'...
            num2str(playListPractice{i}(k).participant) '_' ...
            num2str(playListPractice{i}(k).item) '_' ...
            num2str(playListPractice{i}(k).condition) '.wav'];
        
        playListPractice{i}(k).soundfilename=wavfilename;
        
        wavfilename=[path_soundfiles wavfilename];
        
        %Construct .lab file name
        labfilename=[path_soundfiles,playListPractice{i}(k).experiment...
            '_' num2str(playListPractice{i}(k).participant)...
            '_' num2str(playListPractice{i}(k).item)...
            '_' num2str(playListPractice{i}(k).condition) '.lab'];
        
        %contextFile = [ path_stimuli playListPractice{i}(k).contextFile];
        recordSentence(ws,double(text),wavfilename,labfilename,settings.inputdevice,settings);
        
        %2-Ask question about sentence
        % should eventually also be able to ask picture question
        
        if playListPractice{i}(k).ask=='y'
            [response]=askquestion(ws, settings, playListPractice{i}(k));
        else
            response=playListPractice{i}(k);
        end
        
        %response=playListPractice{i}(k);
        %response=playList(k);
        
        %4---Save Responses in Response File
        
        resultline=struct2cell(response);  % convert structure into cells
        [nColumns a]=size(resultline);
        
        output='';
        
        for l=1:nColumns
            output=[output sprintf('%s\t',num2str(resultline{l}))];
        end
        %output=sprintf('%s\t',output);
        
        %save response
        fid = fopen(responsesPractice,'a','l', 'UTF-8');  %open file and appending
        fprintf(fid,'%s\n',output);
        fclose(fid);  %close file
        
        %prompt='\n\n\n  Tapez la touche <<espace>> quand vous êtes prêts pour le prochain dialogue!';
        %askReady(ws,double(prompt));
        
    end
end


%
%
%
% Experiment
%
%
%
%

% if there are separate instructions for this part
% displayInstructions(ws, [ path_instructions 'instructionsPart1.txt'],settings);

counter(1:nexp)=0;
trialN=0;

% Main loop for the experiment
while max(nTrials-counter)~=0
    
    % this should be 1:nExperiment for other experiments
    for i=1:nexp
        
        exp=experiments(i);
        
        % the condition after & shouldn't be there after other experiments
        if counter(i)<nTrials(i)
            
            if trialN ~= 0
                askReady(ws,double(settings.message3),settings);
            end
            
            trialN=trialN+1;
            
            counter(i)=counter(i)+1;
            k=counter(i);
            
            % add information about participant
            playList{i}(k).participant=participant;
            playList{i}(k).language=participant_language;
            playList{i}(k).playlist=pList(exp);
            playList{i}(k).order=counter(i);
            playList{i}(k).nTrial=trialN;
            
            %1-Display sentence to user
            if isfield(playList{i}(k),'text')
               text= [' - ' playList{i}(k).text];
               if isfield(playList{i}(k),'text2')
                   text=[text '\n\n' playList{i}(k).text2 ];
                   if isfield(playList{i}(k),'text3')
                        text= [text '\n\n' playList{i}(k).text3 ];
                   end
               end
            else
                text=[];
            end
            
            context=[];
            
            if isfield(playList{i}(k),'setup')
                context=playList{i}(k).setup;
            else
                context=[];
            end
            
            if isfield(playList{i}(k),'context')
                context=[ context '\n\n - ' playList{i}(k).context ];
            else
                context=[];
            end
            
            % Check whether a soundfile should be played
            
            if isfield(items{i},'contextFile')
                contextFile=[ path_stimuli playList{i}(k).contextFile];
            else
                contextFile=[];
            end
            
            if isfield(playList{i}(k),'labtext')
                labtext=playList{i}(k).labtext;
            else
                labtext=text;
            end
            
  
            %---Display Text
            
            while KbCheck([-1]); end;
            
            DrawFormattedText(ws.ptr, double(settings.message),50,300,0,settings.textwidth,[],[],1.2);
            
            DrawFormattedText(ws.ptr, double(context),50,400,0,settings.textwidth,[],[],1.2);
            
            DrawFormattedText(ws.ptr, double(text),50,750,0,settings.textwidth,[],[],1.2);
            
            if isfield(playList{i}(k),'picture')
                imdata=imread([ path_stimuli playList{i}(k).picture]);
                
                % make texture image out of image matrix 'imdata'
                %tex=Screen('MakeTexture', ws.ptr, imdata);
                
                % Draw texture image to backbuffer. It will be automatically
                % centered in the middle of the display if you don't specify a
                % different destination:
                %Screen('DrawTexture', ws.ptr, tex);
                
                screen(ws.ptr,'PutImage',imdata,[100 500 300 700]) ;
                
                % Show stimulus on screen at next possible display refresh cycle,
                % and record stimulus onset time in 'startrt':
                
                [VBLTimestamp startrt]=Screen('Flip', ws.ptr);
                
            end
            
            while ~KbCheck([-1]); end;
            
            if recordFile(i)==1
                [recordedaudio]=RecordSound(contextFile,context,text,imdata,1,ws,settings);
                
                %Construct wave file name
                wavfilename=[playList{i}(k).experiment '_'...
                    num2str(playList{i}(k).participant) '_' ...
                    num2str(playList{i}(k).item) '_' ...
                    num2str(playList{i}(k).condition) '.wav'];
                
                playList{i}(k).recordedFile=wavfilename;
                
                wavfilename=[path_soundfiles wavfilename];
                
                wavwrite(transpose(recordedaudio), settings.sampfreq, 16, wavfilename);
                              
                %Save .lab file
                
                %Construct .lab file name
                labfilename=[path_soundfiles,playList{i}(k).experiment...
                    '_' num2str(playList{i}(k).participant)...
                    '_' num2str(playList{i}(k).item)...
                    '_' num2str(playList{i}(k).condition) '.lab'];
                
                fid = fopen([labfilename],'a','l', 'UTF-8');  %open file and appending
                fprintf(fid,'%s\n',labtext);  %print item text to file
                fclose(fid);  %close file
            elseif ~isempty(contextFile)
                PlaySound(settings);
            end
            
            end
           
            response=playList{i}(k);
            
            % Ask Questions if there are any
            
            if isfield(playList{i}(k),'question')
                response=askquestion(ws, settings, response,1);
            else
                response=playList{i}(k);
            end
            
            if isfield(playList{i}(k),'question2')
                response=askquestion(ws, settings, response,2);
            end
            
            if isfield(playList{i}(k),'question3')
                response=askquestion(ws, settings, response,3);
            end
            
            
            
            %---Save Responses in Response File
            
            resultline=struct2cell(response);  % convert structure into cells
            [nColumns a]=size(resultline);
            
            output='';
            
            for l=1:nColumns
                output=[output sprintf('%s\t',num2str(resultline{l}))];
            end
            
            %save response
            fid = fopen(responsesFilename{exp},'a','l', 'UTF-8');  %open file and appending
            fprintf(fid,'%s\n',output);
            fclose(fid);  %close file
            
        end
end


%Display Thank You Screen
Screen('TextSize',ws.ptr,60);
drawText('Thank You!',ws,1);

%ListenChar(0);
end
clear screen