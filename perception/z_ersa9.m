

%Purpose: Main method for experiment
% chael@mcgill.ca 11/17/09
% comments by Erin Olson erin.daphne.olson@gmail.com 11/19/12

% To stop the script at any time, press "command" + "enter"
% If you stop the script during the experiment, you will also have to
% blindly type "clear screen" and hit "enter"

% To get information on any command in this script, type "help " followed
% by the command name

% Closes all windows and clears command history
close all
clear all

% Adds the folder "prosodylabscripts" to the path
addpath('prosodylabscripts');

%
% ----- Configuration --------------
%

% This part of the script sets the number of experiment files
% (spreadsheets) that the script needs to run overall

% number of experiments:
nExperiments = 1;
experiments=1:nExperiments;
[~, nexp]=size(experiments);

% This part of the script sets the number of practice experiments
% (spreadsheets) that the script needs to run - set to 0 because this part
% does not work yet
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
design(1)=4;

% Number of questions a participant is maximially asked per experiment
% Must be equivalent to or higher than the number of question columns in
% your experiment file (spreadsheet)
nQuestions(1)=1;


% Is a file recorded?
% yes = 1; no = 0
recordedFile(nExperiments)=0;
recordFile(1)=0;

% experimentfiles
% these should be a tab-separated files
% only columns that are labeled in the header row will be
% read into a data structure
% Example: item_file{1}='scram.txt';
item_file{1}='ersa9.txt';

% This section tells the script what other folders are necessary for
% running the script
% relevant paths (should be given with final '/'
path_items='1_experiment/';
path_instructions='1_experiment/';
path_stimuli='2_stimuli/';
path_results='2_data/';
path_soundfiles='2_data/1_soundfiles/';

% Load Experiment Settings
% This loads the settings.m file
[settings]=z_settings();

% For dialog-experiments, specify the role of the participant
% 0 = participantA; 1=participantB
% role=0;

%
%  --------- End Configuration ----------------
%

% clear command window
clc

% Read in Experiment Files and Set Up Result File
% For each experiment....
for i=1:nExperiments
    
    % Read in the experiment file
    [items{i},columnNames{i}]=tdfimport([path_items item_file{i}]);
    
    % Read in the response file
    responsesFilename{i}=[path_results items{i}(1).experiment '_responses.txt'];
    
    % If there is no response file...
    if ~exist(responsesFilename{i})
        
        % Add the additional column names as saved in settings.m
        additionalNames=settings.additionalColNames;
        
        % If there is a file recorded, add a column for its name
        if recordFile(i)
            additionalNames=[ additionalNames,'recordedFile' ];
        end
        
        % If there is a sound file to be played, add the columns for onset
        % and offset
        if isfield(items{i},'sound1')
            additionalNames=[additionalNames, 'firstPlayed', 'stimulusOnset_1', 'stimulusOffset_1', 'stimulusOnset_2', 'stimulusOffset_2'];
        end
        
        % If there are columns for questions, add column names for participant responses to questions
        if isfield(items{i},'question')
            additionalNames=[additionalNames ,'response', 'keypress'];
            if isfield(items{i},'question2')
                additionalNames=[ additionalNames ,'response2', 'correct2', 'keypress2'];
                if isfield(items{i},'question3')
                    additionalNames=[ additionalNames ,'response3', 'correct3', 'keypress3'];
                end
            end
            
        end
        
        % Print the additional column names
        additionalNames=sprintf('%s\t',additionalNames{:});
        columnNames{i}=sprintf('%s\t',columnNames{i}{:});
        columnNames{i}=[columnNames{i} additionalNames];
        
        % Write column headers to new response file
        % Open file
        fid = fopen(responsesFilename{i},'a','l', 'UTF-8');
        % Add column names to end of file
        fprintf(fid,'%s\n',columnNames{i});
        % Close the file
        fclose(fid);
    end
end

% Get Participant number
% check whether particpant has already taken part in experiment 1
% if not, detemrine plist number

ok=0;
while ~ok %while ok=0 (which it is initially)
    % Ask for input of participant number
    participant = input('Please enter the participant number: ', 's');
    % Change type of data for participant number from "string" to number
    % and check if ok (if ok, ok=1)
    [participant ok]=str2num(participant);
    if ok
        % Run the checkSetup.m script - generates a playlist (pList) and
        % checks if still ok
        % If not ok, it will display the message "There is already a
        % participant with that number!"
        [pList ok]=checkSetup(participant,design,responsesFilename,nExperiments);
    end
end

% Generate randomized list for participant by using generatePlaylist.m
% Gives back the playlist (playList) - which is a spreadsheet or data frame - and the number of Trials
[playList, nTrials]=generatePlaylist(items,pList,design,experiments);

for i=1:nexp
    % Display the playList number
    disp(['experiment: ' playList{i}(1).experiment ]);
    % Display the design type
    disp(['design: ' designs{design(i)}]);
    % Display the number of Trials
    disp(['length: ' num2str(nTrials)]);   
    % Display the item order
    disp(['item order: ' num2str([playList{i}(:).item ]) ]);
    % Display the condition order
    disp(['condition order: ' num2str([ playList{i}(:).condition ] )]);
end

% Display "ok?" and wait for key press
while KbCheck(-1); end;
disp('ok?');
while ~KbCheck(-1); end;

% Get the keyCode from KbCheck.m (a Psychtoolbox script)
% Note: the ~ in the script below suppresses an output so that only keyCode
% is stored (for more information on keyCode, see the tutorial, second day)
[~, ~, keyCode]=KbCheck(-1);

% If the key pressed is n, this stops the script and asks to change the
% design number (see line 38)
if strcmp('n',KbName(keyCode))
    plistchoice=input('Ok! Please change the design number in the script!', 's');
else

% Displays Psychtoolbox welcome screen
ws = doScreen(settings);
%ListenChar(2);

% Displays instructions file
displayInstructions(ws, [ path_instructions 'instructions.txt'],settings);

%
%
% Practice Session - Not working - skip to line 347
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
while max(nTrials-counter)~=0 % while the number of remaining trials is not 0...
    
    % For 1 to number of experiments...
    for i=1:nexp
        
        % Defines current experiment
        exp=experiments(i);
        
        if counter(i)<nTrials(i) % If the counter is less than the number of trials...
            
            % If the trial number is not 0, display message 3 as defined in
            % settings.m. Otherwise, display message 2.
            if trialN ~= 0
                askReady(ws,double(settings.message3),settings);
            else
                 askReady(ws,double(settings.message2),settings);
            end
            
            % Add 1 to the trial number and counter
            trialN=trialN+1;
            counter(i)=counter(i)+1;
            k=counter(i);
            
            % Adds information about participant to file
            % Must be in the same order as the spreadsheet headers defined
            % starting at line 123
            playList{i}(k).participant=participant;
            playList{i}(k).playlist=pList(exp);
            playList{i}(k).order=counter(i);
            playList{i}(k).nTrial=trialN;
            
            % Store contents of text column(s) to be displayed later
            if isfield(playList{i}(k),'text')
               text= [ playList{i}(k).text];
               if isfield(playList{i}(k),'text2')
                   text=[text '\n\n' playList{i}(k).text2 ];
                   if isfield(playList{i}(k),'text3')
                        text= [text '\n\n' playList{i}(k).text3 ];
                   end
               end
            else % If no text column, no text is stored
                text=[];
            end
            
            context=[];
            
            % Store contents of setup column to be displayed later
            if isfield(playList{i}(k),'setup')
                context=playList{i}(k).setup;
            else % If no setup column, no context is stored
                context=[];
            end
            
            % Store contents of context column to be displayed later
            if isfield(playList{i}(k),'context')
                context=[ context '\n\n [' playList{i}(k).context ']'];
            else % If no context column, no context is stored
                context=[];
            end
            
            % Store contents of sound column to be played later
            if isfield(items{i},'sound1')
                sound1=[ path_stimuli playList{i}(k).sound];
            else % If no sound column, no sound is stored
                sound1=[];
            end
            
            if isfield(items{i},'filler')
                filler=[path_stimuli playList{i}(k).filler];
            else
                filler=[];
            end
            
            if isfield(items{i},'sound2')
                sound2=[ path_stimuli playList{i}(k).sound2];
            else
                sound2=[];
            end
            
            % Store contents of labtext column to be displayed later
            if isfield(playList{i}(k),'labtext')
                labtext=playList{i}(k).labtext;
            else % If no labtext column, the labtext column is the same as the text column
                labtext=text;
            end
                 
            %---Display Text - not currently in use.
            % If not in use, it means that the participant will not see
            % anything different while the sound is playing
            
           % while KbCheck([-1]); end;
            
           % DrawFormattedText(ws.ptr, double(settings.message),50,300,0,settings.textwidth,[],[],1.2);
            
           % DrawFormattedText(ws.ptr, double(context),50,400,0,settings.textwidth,[],[],1.2);
            
           % DrawFormattedText(ws.ptr, double(text),50,600,0,settings.textwidth,[],[],1.2);
            
            
            %Screen('Flip',ws.ptr);
            
            while ~KbCheck([-1]); end; %Waits for key press
            
            % If there is a recorded file (as defined on line 75), run
            % RecordSound.m, which returns a matrix with the recorded audio
            % data.
            if recordFile(i)==1
                [recordedaudio]=RecordSound(contextFile,context,text,1,ws,settings);
                
                %Construct wave file name from the values in the columns
                %"experiment", "participant", "item", "condition" and
                %appends the .wav extension
                wavfilename=[playList{i}(k).experiment '_'...
                    num2str(playList{i}(k).participant) '_' ...
                    num2str(playList{i}(k).item) '_' ...
                    num2str(playList{i}(k).condition) '.wav'];
                
                % Stores the .wav file name to the playList spreadsheet
                playList{i}(k).recordedFile=wavfilename;
                
                % Directs the script where to save the .wav file
                wavfilename=[path_soundfiles wavfilename];
                
                % Writes the recorded audio data to a .wav file
                wavwrite(transpose(recordedaudio), settings.sampfreq, 16, wavfilename);
                              
                %Save .lab file
                %Construct .lab file name from the values in the columns
                %"experiment", "participant", "item", "condition", and
                %appends the .lab extension
                labfilename=[path_soundfiles,playList{i}(k).experiment...
                    '_' num2str(playList{i}(k).participant)...
                    '_' num2str(playList{i}(k).item)...
                    '_' num2str(playList{i}(k).condition) '.lab'];
                
                % Open file
                fid = fopen([labfilename],'a','l', 'UTF-8');
                % Print the stored value "labtext" to the file (defined on
                % line 431) 
                fprintf(fid,'%s\n',labtext);
                % Close file
                fclose(fid);
            
            % Otherwise, if the "sound" column is not empty (see line 424),
            % play the sound back to the participant
            elseif ~isempty(sound1) && ~isempy(sound2)
                
                % randomize
                rand_index=randperm(2);
                soundfiles={[playList{i}(k).sound1] [playList{i}(k).sound2]};
                
                % playback once
                soundfile=[path_stimuli soundfiles{rand_index(1)}];
                [onset1 offset1]=playSound(soundfile,settings);
                WaitSecs(0.25);
                playSound(filler,settings);
                WaitSecs(0.25);
                soundfile=[path_stimuli soundfiles{rand_index(2)}];
                [onset2 offset2]=playSound(soundfile,settings);
                
                % ask for keypress before proceeding
                askReady(ws,settings.message5,settings);
                
                % playback twice
                soundfile=[path_stimuli soundfiles{rand_index(1)}];
                [onset1 offset1]=playSound(soundfile,settings);
                WaitSecs(0.25);
                playSound(filler,settings);
                WaitSecs(0.25);
                soundfile=[path_stimuli soundfiles{rand_index(2)}];
                [onset2 offset2]=playSound(soundfile,settings);
                
                % store data
                playList{i}(k).firstPlayed=rand_index(1);
                playList{i}(k).stimulusOnset_1=onset1;
                playList{i}(k).stimulusOffset_1=offset1;
                playList{i}(k).stimulusOnset_2=onset2;
                playList{i}(k).stimulusOffset_2=offset2;
                
            end
                
            end
            
    end
           
           % Stores the entire playList spreadsheet to the variable
           % "response"
           response=playList{i}(k);
            
            % ----- Ask Questions -------------------------
           
            % Ask Questions (up to 3) if there are any columns for questions in the
            % spreadsheet "response" by using the script askquestion.m
            
            % askquestion.m returns the entire spreadsheet plus the columns
            % for the question data
            
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
            
            
            
            %---Save Responses in Response File------------------
            
            % convert matrix to cell structure
            resultline=struct2cell(response);  
            [nColumns a]=size(resultline);
            output='';
            
            % For each column, print the resulting column to the cell
            % structure
            for l=1:nColumns
                output=[output sprintf('%s\t',num2str(resultline{l}))];
            end
            
            % Save the response file
            % Open file as a UTF8 file
            fid = fopen(responsesFilename{exp},'a','l', 'UTF-8');
            % Print cell structure
            fprintf(fid,'%s\n',output);
            % Close file
            fclose(fid);
            
        end
end


% Display Thank You Screen
Screen('TextSize',ws.ptr,60);
drawText('Thank You!',ws,1);

%ListenChar(0);
clear screen