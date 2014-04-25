% checkSetup
% check participant number and determine playlist
% % chael@mcgill.ca 11/17/09

function [pList, ok]=checkSetup(participant,resultfile,nExperiments,items)

ok = 1;

pList(nExperiments)=1;


for j=1:nExperiments
    
    nPart=[];
    
    [results]=tdfimport(resultfile{j});
    
    [~, nTrials]=size(results);
    
    if nTrials~=0
        
        ok=~(any(ismember([results(:).participant],participant)));
        
        if ~ok
            disp(sprintf(['There is already a participant with that number in experiment ' results(j).experiment '!']));
        else
        
        % plists are kept track of for designs 3-6
        
        design=items{j}(1).design;
        
        
        
        if strcmp(design,'PseudoRandom') || strcmp(design,'LatinSquare')||strcmp(design,'Between') || strcmp(design,'Blocked')
            
            nLists = max([items{j}.condition]);
            plistsToBeRun = 1:nLists;
            
            maxTrial=max([results(:).order]);
            allTrials=[results(:).order];
            completeRuns=allTrials==maxTrial;
            nParticipants=sum(completeRuns);
           
            listsSofar=[results(completeRuns).playlist];
            plistsAlreadyRun=unique(listsSofar);
            assignments = histc(listsSofar,plistsToBeRun);
            maxList=max(plistsAlreadyRun);

            if maxList>nLists
                error('\n%s\n','Problem with PlayList Column in Responses File--a playlist out of range is recorded in responses file!');
            else
                [~, minPlist]=min(assignments);
                pList(j)=minPlist;
            end
            
            disp(sprintf('\n%s',['Experiment: ' results(1).experiment ]));
            
            disp(sprintf('\n%s',['Number of Conditions/Playlists in experiment: ' num2str(nLists)]));
            
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
            
        else
            [~, nParticipants]=size([unique([results(:).participant])]);
            disp(sprintf('\n%s',['Experiment: ' results(1).experiment ]));
            disp(sprintf('\n%s',['Number of Participants: ' num2str(nParticipants) ]));
            pList(j)=1;
            
            while KbCheck(-1); end;
            disp('ok?');
            while ~KbCheck(-1); end;
            
            [~, ~, keyCode]=KbCheck(-1);
        end
        
    end
    
end
end