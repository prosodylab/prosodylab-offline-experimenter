function []=RunExp(experiments,playList,nTrials,pList,participant,recordFile,responsesFilename,settings,session,ws)

[nexp,~]=size(experiments);

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
        if counter(exp)<nTrials(exp)
            
            if trialN ~= 0
                askReady(ws,double(settings.message3),settings);
            end
            
            trialN=trialN+1;
            
            counter(exp)=counter(exp)+1;
            k=counter(exp);
            
            % add information about participant
            playList{exp}(k).participant=participant;
            playList{exp}(k).playList=pList(exp);
            playList{exp}(k).order=counter(exp);
            playList{exp}(k).nTrial=trialN;
            playList{exp}(k).session=session;
            
            %1-Display sentence to user
            if isfield(playList{exp}(k),'text')
                text= [ playList{exp}(k).text ];
                if isfield(playList{exp}(k),'text2')
                    text=[text '\n\n' playList{exp}(k).text2 ];
                    if isfield(playList{exp}(k),'text3')
                        text= [text '\n\n' playList{exp}(k).text3 ];
                    end
                end
            else
                text=[];
            end
            
            context=[];
            
            if isfield(playList{exp}(k),'setup')
                context=playList{exp}(k).setup;
            else
                context=[];
            end
            
            if isfield(playList{exp}(k),'context')
                context=[ context '\n\n' playList{exp}(k).context ];
            else
                context=[];
            end
            
            % Check whether a soundfile should be played
            
            if isfield(playList{exp}(k),'contextFile')
                contextFile=[ settings.path_stimuli playList{exp}(k).contextFile];
            else
                contextFile=[];
            end
            
            if isfield(playList{exp}(k),'labtext')
                labtext=playList{exp}(k).labtext;
            else
                labtext=text;
            end
            
            
            %---Display Text
            
            while KbCheck([-1]); end;
            
            DrawFormattedText(ws.ptr, double(settings.message),settings.messagex,settings.messagey,0,settings.textwidth,[],[],1.2);
            DrawFormattedText(ws.ptr, double(context),settings.contextx,settings.contexty,0,settings.textwidth,[],[],1.2);
            DrawFormattedText(ws.ptr, double(text),settings.textx,settings.texty,0,settings.textwidth,[],[],1.2);
            
            
            Screen('Flip',ws.ptr);
            
            while ~KbCheck([-1]); end;
            
            if recordFile(exp)==1
                
                display=1; % If text should vanish during recording, set to 0;
                
                % show text and context if 'display' is set to true
                
                if ~isempty(ws)
                    
                    if display
                        DrawFormattedText(ws.ptr, double(settings.message),settings.messagex,settings.messagey,0,settings.textwidth,[],[],1.2);
                        DrawFormattedText(ws.ptr, double(context),settings.contextx,settings.contexty,0,settings.textwidth,[],[],1.2);
                        DrawFormattedText(ws.ptr, double(text),settings.textx,settings.texty,0,settings.textwidth,[],[],1.2);
                        
                        Screen('Flip',ws.ptr);
                    else
                        Screen('DrawText', ws.ptr, double(settings.message2),50,[settings.messageheight]);
                        Screen('Flip',ws.ptr);
                    end
                end
                              
                [recordedaudio]=RecordSound(contextFile,settings, ws);
                
                %Construct wave file name
                wavfilename=[playList{exp}(k).experiment '_'...
                    num2str(playList{exp}(k).participant) '_' ...
                    num2str(playList{exp}(k).item) '_' ...
                    num2str(playList{exp}(k).condition) '.wav'];
                
                playList{exp}(k).recordedFile=wavfilename;
                
                wavfilename=[settings.path_soundfiles wavfilename];
                
                wavwrite(transpose(recordedaudio), settings.sampfreq, 16, wavfilename);
                
                %Save .lab file
                
                %Construct .lab file name
                labfilename=[settings.path_soundfiles,playList{i}(k).experiment...
                    '_' num2str(playList{i}(k).participant)...
                    '_' num2str(playList{i}(k).item)...
                    '_' num2str(playList{i}(k).condition) '.lab'];
                
                fid = fopen([labfilename],'a','l', 'UTF-8');  %open file and appending
                fprintf(fid,'%s\n',labtext);  %print item text to file
                fclose(fid);  %close file
            elseif ~isempty(contextFile)
                PlaySound(settings);
            end
            
            
            
            response=playList{exp}(k);
            
            % Ask Questions if there are any
            
            if isfield(playList{exp}(k),'question')
                response=askquestion(ws, settings, response,1);
            else
                response=playList{exp}(k);
            end
            
            if isfield(playList{exp}(k),'question2')
                response=askquestion(ws, settings, response,2);
            end
            
            if isfield(playList{exp}(k),'question3')
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
end

end