
% tester script
% practice runs

close all
clear all

addpath('prosodylabscripts');

nExperiments = 1;
experiments=1:nExperiments;
[~, nexp]=size(experiments);

practice = 1;
designs={'Fixed' 'Random' 'PseudoRandom' 'LatinSquare' 'Blocked'};
design(1) = 2;

item_file{1}='ersa9.txt';

path_items='1_experiment/';
path_instructions='1_experiment/';
path_stimuli='2_stimuli/';
path_results='2_data/';
path_soundfiles='2_data/1_soundfiles/';

[settings]=z_settings();

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
end

% Displays Psychtoolbox welcome screen
% ws = doScreen(settings);
% ListenChar(2);

% Displays instructions file
% displayInstructions(ws, [ path_instructions 'instructions.txt'],settings);


%
%
% Practice Session - TEST
%
%

if practice==1
    
    disp('hello')
    
    [itemsPractice{1},columnsPractice]=tdfimport([ path_items item_file{1}]);
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
