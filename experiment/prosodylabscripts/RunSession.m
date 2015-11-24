function []=RunSession(sessionNumber,experiments, playList,nTrials,pList,participant,responsesFilename,settings,ws)

%
% Run an Experimental Session
%
%

nexp=length(experiments);
counter(1:nexp)=0;
trialN=0;

maxTrials=max(nTrials(experiments))

% Main loop for the session
while maxTrials-max(counter)>0
    
    % run through one trial from each experiment
    for i=1:nexp
        
        exper=experiments(i);
        % =find(strcmp({experimentNames{:}}, expname));
        
        % the condition after & shouldn't be there after other experiments
        if counter(i)< nTrials(exper)
               
            if trialN ~= 0
                askReady(ws,double(settings.message3),settings);
            end
            
            trialN=trialN+1;
            
            counter(i)=counter(i)+1;
            k=counter(i);
            
            % add information about participant
            playList{exper}(k).participant=participant;
            playList{exper}(k).playList=pList(exper);
            playList{exper}(k).sessionTrial=counter(i);
            playList{exper}(k).experimentTrial=trialN;
            playList{exper}(k).session=sessionNumber;
            todaysdate=num2str(date);
            starttime=num2str(datestr(now,13));
            
            %1-Display sentence to user
            if isfield(playList{exper}(k),'text')
                text= [ playList{exper}(k).text ];
                if isfield(playList{exper}(k),'text2')
                    text=[text '\n\n' playList{exper}(k).text2 ];
                    if isfield(playList{exper}(k),'text3')
                        text= [text '\n\n' playList{exper}(k).text3 ];
                    end
                end
            else
                text=[];
            end
            
            
            if isfield(playList{exper}(k),'setup')&&~(strcmp(playList{exper}(k).setup,''))
                context=[ '[' playList{exper}(k).setup ']'];
            else
                context=[];
            end
            
            if isfield(playList{exper}(k),'context')
                context=[ playList{exper}(k).context '\n\n' context ];
            else
                context=[];
            end
            
            
            
            % Check whether a soundfile should be played
            
            if isfield(playList{exper}(k),'contextFile')
                contextFile=[ settings.path_contexts playList{exper}(k).contextFile];
            else
                contextFile=[];
            end
            
            if isfield(playList{exper}(k), 'answerFile')
                answerFile = [settings.path_answers playList{exper}(k).answerFile];
            else
                answerFile=[];
            end
            
            if isfield(playList{exper}(k), 'answerFile2')
                answerFile2 = [settings.path_answers playList{exper}(k).answerFile2];
            else
                answerFile2 = [];
            end
            
            
            if isfield(playList{exper}(k),'lab')
                labtext=playList{exper}(k).lab;
            elseif isfield(playList{exper}(k),'text')
                labtext=playList{exper}(k).text;
            else
                labtext=[];
            end
            
            if isfield(playList{exper}(k),'retrial')
                retrial=playList{exper}(k).retrial;
            else
                retrial='n';
            end
            
            
            %---Display Text and Image (if there is one)
            
            tic;
            
            while true
                
                while KbCheck([-1]); end;
                
                % display image if there is an image column
                if isfield(playList{i}(k),'image')
                    if playList{i}(k).picture~=''
                        imdata=imread([ path_images  playList{i}(k).picture]);
                        
                        %[x,y]=size(imdata);
                        
                        % make texture image out of image matrix 'imdata'
                        %tex=Screen('MakeTexture', ws.ptr, imdata);
                        
                        % Draw texture image to backbuffer. It will be automatically
                        % centered in the middle of the display if you don't specify a
                        % different destination (see Psychtoolbox Screen command):
                        
                        Screen(ws.ptr,'PutImage',imdata) ;
                        
                        % Show stimulus on screen at next possible display refresh cycle,
                        % and record stimulus onset time in 'startrt':
                    end
                end
                
                DrawFormattedText(ws.ptr, double(settings.message),settings.messagex,settings.messagey,0,settings.textwidth,[],[],1.2);
                DrawFormattedText(ws.ptr, double(context),settings.contextx,settings.contexty,0,settings.textwidth,[],[],1.2);
                DrawFormattedText(ws.ptr, double(text),settings.textx,settings.texty,0,settings.textwidth,[],[],1.2);
                
                
                Screen('Flip',ws.ptr);
                
                while ~KbCheck([-1]); end;
                
                
                if ~isempty(contextFile)
                    playSound(contextFile, settings);
                end
                
                record='n';
                
                if isfield(playList{exper}(k),'record')
                    if  ismember(playList{exper}(k).record,{'y','Y','YES','yes','Yes'})
                        record='y';
                    elseif ismember(playList{exper}(k).record,{'twice','Twice'})
                        record='twice';
                    elseif ismember(playList{exper}(k).record,{'memorized','Memorized'})
                        record='memorized';
                    elseif ismember(playList{exper}(k).record,{'paced','Paced'})
                        record='paced';
                    end
                end
                
                if strcmp(record,'y')||strcmp(record,'twice')||strcmp(record,'memorized')
                    
                    if ~isempty(ws)
                         % text disappears for recording if 'memorized'
                        if ~strcmp(record,'memorized')
                            DrawFormattedText(ws.ptr, double(settings.message2),settings.messagex,settings.messagey,[255, 0, 0, 255],settings.textwidth,[],[],1.2);
                            DrawFormattedText(ws.ptr, double(context),settings.contextx,settings.contexty,0,settings.textwidth,[],[],1.2);
                            DrawFormattedText(ws.ptr, double(text),settings.textx,settings.texty,0,settings.textwidth,[],[],1.2);
                            
                            Screen('Flip',ws.ptr);
                        else
                            Screen('DrawText', ws.ptr, double(settings.message2),50,[settings.messageheight]);
                            Screen('Flip',ws.ptr);
                        end
                    end
                    
                    % records files --> we don't want to record we want to play
                    % files
                    
                    [recordedaudio]=RecordSound(settings, ws);
                    
                    %Construct wave file name
                    wavfilename=[playList{exper}(k).experiment '_'...
                        num2str(playList{exper}(k).participant) '_' ...
                        num2str(playList{exper}(k).item) '_' ...
                        num2str(playList{exper}(k).condition) '.wav'];
                    
                    playList{exper}(k).recordedFile=wavfilename;
                    
                    wavfilename=[settings.path_soundfiles wavfilename];
                    
                    wavwrite(transpose(recordedaudio), settings.samplingFrequency, 16, wavfilename);
                    
                    %Save .lab file
                    
                    %Construct .lab file name
                    labfilename=[settings.path_soundfiles,playList{exper}(k).experiment...
                        '_' num2str(playList{exper}(k).participant)...
                        '_' num2str(playList{exper}(k).item)...
                        '_' num2str(playList{exper}(k).condition) '.lab'];
                    
                    fid = fopen([labfilename],'a','l', 'UTF-8');  %open file and appending
                    fprintf(fid,'%s\n',labtext);  %print item text to file
                    fclose(fid);  %close file
                
                elseif strcmp(record,'paced')
                    
                    % Parts of the upcoming  textto be read will be revealed after
                    % initiating speaking on the prior zone of interest
                    
                    chunks=strsplit(playList{exper}(k).zoi,'_');
                    
                    [recordedaudio,trigger]=pacedRecording(chunks,settings,ws);
                    
                    playList{exper}(k).trigger=trigger;
                    
                    %Construct wav file name
                    wavfilename=[playList{exper}(k).experiment '_'...
                        num2str(playList{exper}(k).participant) '_' ...
                        num2str(playList{exper}(k).item) '_' ...
                        num2str(playList{exper}(k).condition) '.wav'];
                    
                    playList{exper}(k).recordedFile=wavfilename;
                    
                    wavfilename=[settings.path_soundfiles wavfilename];
                    
                    wavwrite(transpose(recordedaudio), settings.samplingFrequency, 16, wavfilename);
                    
                    %Save .lab file
                    
                    %Construct .lab file name
                    labfilename=[settings.path_soundfiles,playList{exper}(k).experiment...
                        '_' num2str(playList{exper}(k).participant)...
                        '_' num2str(playList{exper}(k).item)...
                        '_' num2str(playList{exper}(k).condition) '.lab'];
                    
                    fid = fopen(labfilename,'a','l', 'UTF-8');  %open file and appending
                    fprintf(fid,'%s\n',labtext);  %print item text to file
                    fclose(fid);  %close file
                    
                end
                
                if strcmp(record,'twice')
                    
                    display=1; % If text should vanish during recording, set to 0;
                    
                    % show text and context if 'display' is set to true
                    
                    if ~isempty(ws)
                        
                        if display
                            DrawFormattedText(ws.ptr, double(settings.message5),settings.messagex,settings.messagey,[255, 0, 0, 255],settings.textwidth,[],[],1.2);
                            DrawFormattedText(ws.ptr, double(context),settings.contextx,settings.contexty,0,settings.textwidth,[],[],1.2);
                            DrawFormattedText(ws.ptr, double(text),settings.textx,settings.texty,0,settings.textwidth,[],[],1.2);
                            
                            Screen('Flip',ws.ptr);
                        else
                            Screen('DrawText', ws.ptr, double(settings.message2),50,[settings.messageheight]);
                            Screen('Flip',ws.ptr);
                        end
                    end
                    
                    % records files --> we don't want to record we want to play
                    % files
                    
                    [recordedaudio]=RecordSound(settings, ws);
                    
                    %Construct wave file name
                    wavfilename=[playList{exper}(k).experiment '_'...
                        num2str(playList{exper}(k).participant) '_' ...
                        num2str(playList{exper}(k).item) '_' ...
                        num2str(playList{exper}(k).condition) '_second.wav'];
                    
                    playList{exper}(k).secondRecordFile=wavfilename;
                    
                    wavfilename=[settings.path_soundfiles wavfilename];
                    
                    wavwrite(transpose(recordedaudio), settings.samplingFrequency, 16, wavfilename);
                    
                    %Save .lab file
                    
                    %Construct .lab file name
                    labfilename=[settings.path_soundfiles,playList{exper}(k).experiment...
                        '_' num2str(playList{exper}(k).participant)...
                        '_' num2str(playList{exper}(k).item)...
                        '_' num2str(playList{exper}(k).condition) '_second.lab'];
                    
                    fid = fopen([labfilename],'a','l', 'UTF-8');  %open file and appending
                    fprintf(fid,'%s\n',labtext);  %print item text to file
                    fclose(fid);  %close file
                    
                end
                
                % play anwer files if there are any
                
                if  ~isempty(answerFile)
                    WaitSecs(0.5);
                    playSound(answerFile, settings);
                end
                
                if ~isempty(answerFile2)
                    WaitSecs(0.5);
                    playSound(answerFile2, settings);
                end
                
                
                if retrial=='y'
                    
                    DrawFormattedText(ws.ptr, double(settings.retrialMessage),settings.messagex,settings.messagey,0,settings.textwidth,[],[],1.2);
                    Screen('Flip',ws.ptr);
                    
                    [pressed_key, resp_time]= getResponseKeypad({'y','n'},inf);
                    
                    if length(pressed_key)>1
                        pressed_key=pressed_key(1);
                    end
                    
                    if isempty(pressed_key)
                        pressed_key=0;
                    end
                    
                    retrial=pressed_key;
                    
                    while ~KbCheck([-1]); end;
                end
                
                if strcmp(retrial,'n')
                    break;
                else
                    askReady(ws,double(settings.retrialMessage2),settings);
                end
            end
            
            response=playList{exper}(k);
            
            % Ask Questions if there are any
            
            %check that contents of field question ~= "no".
            if isfield(playList{exper}(k),'question') && ~strcmpi(playList{exper}(k).question,'no')
                
                response.response='';
                response.correct='';
                response.rt='';
                response=askquestion(ws, settings, response,1);
            else
                response=playList{exper}(k);
            end
            
            if isfield(playList{exper}(k),'question2') && ~strcmpi(playList{exper}(k).question2,'no')
                response.response2='';
                response.correct2='';
                response.rt2='';
                response=askquestion(ws, settings, response,2);
            end
            
            if isfield(playList{exper}(k),'question3')&& ~strcmpi(playList{exper}(k).question3,'no')
                response.response3='';
                response.correct3='';
                response.rt3='';
                response=askquestion(ws, settings, response,3);
            end
            
            
            %---Save Responses in Response File
            
            
            response.trialDuration=toc;
            response.date=todaysdate;
            response.trialStart=starttime;
            response.trialEnd=num2str(datestr(now,13));
            
            
            resultline=struct2cell(response);  % convert structure into cells
            [nColumns, ~]=size(resultline);
            
            output='';
            
            for l=1:nColumns
                output=[output sprintf('%s\t',num2str(resultline{l}))];
            end
            
            %save response
            fid = fopen(responsesFilename,'a','l', 'UTF-8');  %open file and appending
            fprintf(fid,'%s\n',output);
            fclose(fid);  %close file
        end
    end
end

end