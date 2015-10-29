% checkSetup
% check participant number and determine playlist

function [pList, ok]=checkSetup(participant,responsesFilename,experimentNames,items)

nExperiments=length(unique(experimentNames));
pList(1:nExperiments)=1;

[allResults]=tdfimport(responsesFilename);
[~,rows]=size(allResults);

if rows ~= 0
    
    ok=~(any(ismember([allResults(:).participant],participant)));
    if ~ok
        disp(sprintf(['There is already a participant with that number!']));
    else
        if rows > 1
            
            for j=1:nExperiments
                
                nPart=[];
                
                results=allResults(strcmp({allResults.experiment},experimentNames(j)));
                
                [~, nTrials]=size(results);
                
                if nTrials~=0
                    
                    % plists are kept track of for designs 3-6
                    
                    design=items{j}(1).design;
                    
                    nCond = max([items{j}.condition]);
                    nItem = max([items{j}.item]);
                    
                    if strcmp(design,'LatinSquare')||strcmp(design,'Between')
                        maxTrial=nItem;
                    else
                        maxTrial=nCond*nItem;
                    end
                    
                    if strcmp(design,'LatinSquare')||strcmp(design,'Between')||strcmp(design,'Within')||strcmp(design,'Blocked')
                        plistsToBeRun = 1:nCond;
                    else
                        plistsToBeRun = 1;
                    end
                    
                    allTrials=[results(:).experimentTrial];
                    completeRuns=allTrials==maxTrial;
                    nParticipants=sum(completeRuns);
                    
                    listsSofar=[results(completeRuns).playlist];
                    plistsAlreadyRun=unique(listsSofar);
                    assignments = histc(listsSofar,plistsToBeRun);
                    maxList=max(plistsAlreadyRun);
                    
                    
                    
                    if maxList>nCond
                        error('\n%s\n','Problem with PlayList Column in Responses File--a playlist out of range is recorded in responses file!');
                    elseif sum(completeRuns)~=0
                        [~, minPlist]=min(assignments);
                        pList(j)=minPlist;
                    else
                        pList(j)=1;
                    end
                    
                    disp(sprintf('\n%s',['Experiment: ' results(1).experiment ]));
                    
                    disp(sprintf('\n%s',['Number of Conditions/Playlists in experiment: ' num2str(nCond)]));
                    
                    disp(sprintf('\n%s',['Names of Participants that have completed the experiment: ' num2str(nParticipants)]));
                    
                    disp(sprintf('\n%s',['Names of Playlists that have been played: ' num2str(plistsAlreadyRun)]));
                    
                    disp(sprintf('%s',['Number of Participants that completed each list: ' num2str(assignments)]));
                    
                    disp(sprintf('%s',['This adds up to:  ' num2str(sum(assignments)) '  and should be equal to # participants. ']));
                    
                    disp(sprintf('\n%s\n',['Assigned Playlist: ' num2str(pList(j)) '   (should be the one with least participants)']));
                    
                    
                    while KbCheck(-1); end;
                    disp('ok (# of particpants per playlist should be balanced)?');
                    while ~KbCheck(-1); end;
                    
                    [~, ~, keyCode]=KbCheck(-1);
                    
                    if strcmp('n',KbName(keyCode))
                        plistchoice=input('Please enter the desired playlist number: ', 's');
                        pList(j)=str2num(plistchoice);
                    end
                    
                    
                end
            end
        end
        
    end
else
    ok=1;
end
end