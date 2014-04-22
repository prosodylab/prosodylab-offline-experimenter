%Purpose: Create playlist of sentences
% chael@mcgill.ca 02/19/12


function [playList,nTrials]=generatePlaylist(items,pList,experiments)

% Designs:
% decides how the trials will be ordered
% and whether it's latin square or not
% Options:
% 1 : Fixed (No Randomization):
%     Play all trials in the order of spreadsheet
%     column "condition" and "item" will be ignored
% 2 : Random:
%     Play all trials in random order
%     column "condition" and "item" will be ignored
% 3 : PseudoRandom:
%     Every condition from every item for each participant
%     Items aren't repeated more than once (in fact, a repetition of same
%     item can only happen once per experiment)
%     Conditions can only be repeated once
%     Number of items has to be divisible by number of conditions
% 4 : LatinSquare:
%     Only one condition from each item per subject
%     number of items has to be divisible by number of conditions
%     There will be as many playlists (=groups of participants)
%     as there are conditions
% 5 : Between:
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
    design=items{exp}(1).design;
    
    
    trial=0;
    
    if strcmp(design,'Fixed')
        playList{exp}=items{exp};
        [~,length]=size(playList{exp});
        nTrials(exp)=length;
        
    elseif strcmp(design,'Random')
        % All trials, random order
        playList{exp}=items{exp};
        [~,length]=size(playList{exp});
        % Randomize Order
        rTrial=randperm(length);
        for i=1:length
            newList(i)=playList{exp}(rTrial(i));
        end
        playList{exp}=newlist;
        nTrials(exp)=length;
        
    elseif strcmp(design,'PseudoRandom')
        % Pseudo-Random, Each Condition from Each Item for Each Participant
        % each block like latin square design with one condition from each
        % item
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
        
        
    elseif strcmp(design,'LatinSquare')
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
        
        
    elseif strcmp(design,'Between')
        %Between: Every subject sees only one condition
        
        nItems=max([items{exp}(:).item]);
        nConditions=max([items{exp}(:).condition]);
        
        disp(['playlist of exp: ' num2str(pList(exp)) '   nitem/ncon:  ' num2str(nItems) ' \ ' num2str(nConditions) ]);
        
        %Loop through items
        for i=1:nItems
            selectCondition=pList(exp);
            selectItem=i-1;
            index=selectItem*nConditions+selectCondition;
            playList{exp}(i)=items{exp}(index);
        end
        
        rTrial=randperm(nItems);
        for i=1:nItems
            newList(i)=playList{exp}(rTrial(i));
        end
        
        playList{exp}=newList;
        nTrials(exp)=nItems;
        
    elseif strcmp(design,'Blocked')
        %Blocked: Every subject sees all conditions, but in separate
        %consecutive blocks (blocks in random order)
             
        nItems=max([items{exp}(:).item]);
        nConditions=max([items{exp}(:).condition]);
        
        disp(['playlist of exp: ' num2str(pList(exp)) '   nitem/ncon:  ' num2str(nItems) ' \ ' num2str(nConditions) ]);
        
        %Loop through items
        for j=1:nConditions
            selectCondition=mod(j+pList(exp)-1,nConditions)+1;
            for i=1:nItems
                selectItem=i;
                trial=(j-1)*nItems+i;
                index=selectItem*nConditions-selectCondition+1;
                playList{exp}(trial)=items{exp}(index);
            end
        end
        
        rCond=randperm(nConditions);
        for j=1:nConditions
            selectCondition=rCond(j);
            rTrial=randperm(nItems);
            for i=1:nItems
                newTrial=(j-1)*nItems+i;
                trial=(selectCondition-1)*nItems+rTrial(i);
                newList(newTrial)=playList{exp}(trial);
            end
        end
        
        playList{exp}=newList;
        nTrials(exp)=nConditions*nItems;
        
    else
        
        error(['design: ' num2str(design) 'is  unknown!'])
    
    
end

end
