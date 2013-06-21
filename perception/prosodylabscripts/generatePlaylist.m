%Purpose: Create playlist of sentences
% chael@mcgill.ca 02/19/12


function [playList,nTrials]=generatePlaylist(items,pList,design,experiments)

% Design:
% decides how the trials will be ordered
% and whether it's latin square or not
% Options:
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
% 5 : Between Subjects:
%     Each participant see sonly one conditions.
%     number of items has to be divisible by number of conditions
%     There will be as many playlists (=groups of participants)
%     as there are conditions
% 6 : Blocked:
%     Each participants see all conditions but blocked.
%     number of items has to be divisible by number of conditions
%     There will be as many playlists (=groups of participants)
%     as there are conditions


[~, nExperiments]=size(experiments);

for k=1:nExperiments
    
    exp=experiments(k);
    
    
    trial=0;
    
    if design(exp)==1
        % Fixed Order
        playList{exp}=items{exp};
        [~,length]=size(playList{exp});
        nTrials(exp)=length;
        
    elseif design(exp)==2
        % All trials, random order
        playList{exp}=items{exp};
        [~,length]=size(playList{exp});
        % Randomize Order
        rTrial=randperm(length);
        for i=1:length
            newList(i)=playList{exp}(rTrial(i));
        end
        playList{exp}=newList;
        nTrials(exp)=length;
        
    elseif design(exp)==3
        % Pseudo-Random, Each Condition from Each Item for Each Participant
        
        nItems=max([items{exp}(:).item]);
        nConditions=max([items{exp}(:).condition]);
        
        disp(['playlist of exp: ' num2str(pList(exp)) '   nitem/ncon:  ' num2str(nItems) ' \ ' num2str(nConditions) ]);
        
        % Create Latin-Square-Style Playlists with randomized item selection
        % and order Playlists in Random Order
        nBlocks=nItems/nConditions;
        rCondition=randperm(nConditions);
        trial=0;
        
        %Loop for Playlists
        for h=1:nConditions
            
            %Randomize distance between items pairs
            itemDistance=floor(nBlocks*rand);
            
            %Loop through Blocks
            for j=1:nBlocks
                
                %Loop through conditions within Block
                for i=1:nConditions
                    trial=trial+1;
                    %select Condition
                    conditionSelector=(j-1)*nConditions+i;
                    selectCondition = conditionSelector+rCondition(h)-nConditions*(floor((conditionSelector+rCondition(h))/nConditions))+1;
                    %select item
                    selectItem=(j-1)*nConditions+i;
                    selectItem=selectItem+(itemDistance*nConditions*(i-1));
                    selectItem=selectItem-(floor(selectItem/nItems))*nItems+1;
                    %select trial (=row in spreadsheet) based on condition
                    %and item
                    index=selectItem*nConditions-selectCondition+1;
                    playList{exp}(trial)=items{exp}(index);
                end
            end
        end
        
        % Randomize the order of Blocks within Each PlayList
        rBlock=randperm(nBlocks);
        counter=0;
        for h=1:nConditions
            for i=1:nBlocks
                for j=1:nConditions
                    counter=counter+1;
                    newlist(counter)=playList{exp}((h-1)*nItems+(rBlock(i)-1)*nConditions+j);
                    
                end
            end
        end
        playList{exp}=newlist;
        
        
        % Randomize the order of Conditions Within each Block of Trials Within Each PlayList
        nBlocks=nItems/nConditions;
        counter=0;
        for h=1:nConditions
            for i=1:nBlocks
                rCondition=randperm(nConditions);
                for j=1:nConditions
                    counter=counter+1;
                    newlist(counter)=playList{exp}((h-1)*nItems+(i-1)*nConditions+rCondition(j));
                end
            end
        end
        playList{exp}=newlist;
        nTrials(exp)=nConditions*nItems;
        
        
    elseif design(exp)==4
        % Latin Square: One condition from each item for each participant
        
        
        nItems=max([items{exp}(:).item]);
        nConditions=max([items{exp}(:).condition]);
        
        disp(['playlist of exp: ' num2str(pList(exp)) '   nitem/ncon:  ' num2str(nItems) ' \ ' num2str(nConditions) ]);
        
        %
        nBlocks=nItems/nConditions;
        itemDistance=floor(nBlocks*rand);
        
        %Loop through Blocks
        for j=1:nBlocks
            
            %Loop through conditions within Block
            for i=1:nConditions
                trial=trial+1;
                %select Condition
                conditionSelector=(j-1)*nConditions+i;
                selectCondition = conditionSelector+pList(exp)+1-nConditions*(floor((conditionSelector+pList(exp)+1)/nConditions))+1;
                %select item
                selectItem=(j-1)*nConditions+i;
                selectItem=selectItem+(itemDistance*nConditions*(i-1));
                selectItem=selectItem-(floor(selectItem/nItems))*nItems+1;
                %select trial (=row in spreadsheet) based on condition
                %and item
                index=selectItem*nConditions-selectCondition+1;
                playList{exp}(trial)=items{exp}(index);
            end
        end
        
        % Randomize the order of Blocks within Each PlayList
        rBlock=randperm(nBlocks);
        trial=0;
        for i=1:nBlocks
            for j=1:nConditions
                trial=trial+1;
                newlist(trial)=playList{exp}((rBlock(i)-1)*nConditions+j);
            end
        end
        playList{exp}=newlist;
        
        
        % Randomize the order of Conditions Within each Block of Trials Within Each PlayList
        trial=0;
        for i=1:nBlocks
            rCondition=randperm(nConditions);
            for j=1:nConditions
                trial=trial+1;
                newlist(trial)=playList{exp}((i-1)*nConditions+rCondition(j));
            end
        end
        
        playList{exp}=newlist;
        nTrials(exp)=nItems;
        
        
    elseif design(k)==5
        %Blocked: Every subject sees only one condition
        
        nItems=max([items{exp}(:).item]);
        nConditions=max([items{exp}(:).condition]);
        
        disp(['playlist of exp: ' num2str(pList(exp)) '   nitem/ncon:  ' num2str(nItems) ' \ ' num2str(nConditions) ]);
        
        %Loop through items
        for i=1:nItems
            selectCondition=pList(exp);
            selectItem=i;
            index=selectItem*nConditions-selectCondition+1;
            playList{exp}(i)=items{exp}(index);
        end
        
        rTrial=randperm(nItems);
        for i=1:nItems
            newList(i)=playList{exp}(rTrial(i));
        end
        
        playList{exp}=newList;
        nTrials(exp)=nItems;
        
    elseif design(k)==6
        % Blocked: Every subject sees only all conditions, but blocked.
        % As many playlists as conditions
        % playlist defined by which condition comes first, other condtions
        % are presented in random order
        
        nItems=max([items{exp}(:).item]);
        nConditions=max([items{exp}(:).condition]);
        
        disp(['playlist of exp: ' num2str(pList(exp)) '   nitem/ncon:  ' num2str(nItems) ' / ' num2str(nConditions) ]);
        
        %Loop through items
        
         condirand=randperm(nConditions);
        while condirand(1)~=pList(exp);
            condirand=randperm(nConditions);
        end
        
        for j=1:nConditions
            jrand=condirand(j);
            condi=1+mod((jrand-1),nConditions);
            disp(num2str(condi));
            for i=1:nItems
                selectCondition=condi;
                selectItem=i;
                trial=i+(j-1)*nItems;
                index=selectItem*nConditions-(nConditions-selectCondition+1)+1;
                playList{exp}(trial)=items{exp}(index);
            end
        end
        
        for j=1:nConditions
            rTrial=randperm(nItems);
            for i=1:nItems
                newTrial=(j-1)*nItems+i;
                trial=(j-1)*nItems+rTrial(i);
                newList(newTrial)=playList{exp}(trial);
            end
        end
        
        playList{exp}=newList;
        nTrials(exp)=nConditions*nItems;
        
    end
    
    
end

end