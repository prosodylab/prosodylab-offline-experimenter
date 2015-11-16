%Purpose: Create playlist of sentences

function [playList,nTrials]=generatePlaylist(items,pList,experimentNames)

% % design: Should be specified in column 'design' in experiment spreadsheet
% Options:
%
designs={'Between' 'Blocked' 'BlockedFixed' 'Fixed'  'LatinSquare' 'Random' 'Within'};
%
% designs requiring spreadsheet to be ordered by item and then condition:
pickyDesigns={'LatinSquare' 'Within'};
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
%     Conditions can only be repeated once
%     Number of items has to be divisible by number of conditions


nExperiments=length(unique(experimentNames));

for k=1:nExperiments
    
    exper=k;
    trial=0;
    design=items{exper}(1).design;
    
    % sort by item and then condition if design requires it
    if ismember(design,pickyDesigns)

        % identify item and condition columns:
        itemFields=fieldnames(items{exper});
        itemColumn=find(ismember(itemFields,'item'));
        conditionColumn=find(ismember(itemFields,'condition'));
        
        % convert to cell and then to matrix, in order to sort:
        itemSorted=struct2cell(items{exper});
        sz = size(itemSorted);
        itemSorted=reshape(itemSorted, sz(1), []);
        itemSorted=itemSorted';
        % sort by item and then by condition (opposite order necessary):
        itemSorted = sortrows(itemSorted, conditionColumn);
        itemSorted = sortrows(itemSorted, itemColumn);
        % convert back to cell array and then structure:
        itemSorted=reshape(itemSorted', sz);
        itemSorted = cell2struct(itemSorted, itemFields, 1);

    end
    
    if strcmp(design,'Fixed')
        playList{exper}=items{exper};
        [~,elength]=size(playList{exper});
        nTrials(exper)=elength;
        
    elseif strcmp(design,'Random')
        playList{exper}=items{exper};
        % All trials, completely random order
        [~,elength]=size(playList{exper});
        nTrials(exper)=elength;
        % Randomize Order
        rTrial=randperm(elength);
        for i=1:elength
            newList(i)=playList{exper}(rTrial(i));
        end
        playList{exper}=newList;
        
    elseif strcmp(design,'Within')
        %
        nItems=max([items{exper}(:).item]);
        nConditions=max([items{exper}(:).condition]);
        
        if round(nItems/nConditions)~=nItems/nConditions
            error(['For design ' design ', number of items (' num2str(nItems) ') has to be divisible by number of conditions(' num2str(nConditions) ')!']);
        end
        
        % Create several Latin-Square-Style Playlists with randomized item selection
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
                    playList{exper}(trial)=items{exper}(index);
                end
            end
        end
        
        % Randomize the order of Blocks within Each PlayList
        rBlock=randperm(nBlocks);
        counter=0;
        newlist=items{exper}(1);
        for h=1:nConditions
            for i=1:nBlocks
                for j=1:nConditions
                    counter=counter+1;
                    newlist(counter)=playList{exper}((h-1)*nItems+(rBlock(i)-1)*nConditions+j);
                    
                end
            end
        end
        playList{exper}=newlist;
        
        % Randomize the order of Conditions Within each Block of Trials Within Each PlayList
        nBlocks=nItems/nConditions;
        counter=0;
        newlist=items{exper}(1);
        for h=1:nConditions
            for i=1:nBlocks
                rCondition=randperm(nConditions);
                for j=1:nConditions
                    counter=counter+1;
                    newlist(counter)=playList{exper}((h-1)*nItems+(i-1)*nConditions+rCondition(j));
                end
            end
        end
        playList{exper}=newlist;
        nTrials(exper)=nConditions*nItems;
        
        
    elseif strcmp(design,'LatinSquare')
        % Latin Square: One condition from each item for each participant
        
        nItems=max([items{exper}(:).item]);
        nConditions=max([items{exper}(:).condition]);
        
        if round(nItems/nConditions)~=nItems/nConditions
            error(['For design ' design ', number of items (' num2str(nItems) ') has to be divisible by number of conditions(' num2str(nConditions) ')!']);
        end
        
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
                selectCondition = conditionSelector+pList(exper)+1-nConditions*(floor((conditionSelector+pList(exper)+1)/nConditions))+1;
                %select item
                selectItem=(j-1)*nConditions+i;
                selectItem=selectItem+(itemDistance*nConditions*(i-1));
                selectItem=selectItem-(floor(selectItem/nItems))*nItems+1;
                %select trial (=row in spreadsheet) based on condition
                %and item
                index=selectItem*nConditions-selectCondition+1;
                playList{exper}(trial)=items{exper}(index);
            end
        end
        
        % Randomize the order of Blocks within Each PlayList
        rBlock=randperm(nBlocks);
        trial=0;
        newlist=items{exper}(1);
        for i=1:nBlocks
            for j=1:nConditions
                trial=trial+1;
                newlist(trial)=playList{exper}((rBlock(i)-1)*nConditions+j);
            end
        end
        playList{exper}=newlist;
        
        
        % Randomize the order of Conditions Within each Block of Trials Within Each PlayList
        trial=0;
        newlist=items{exper}(1);
        for i=1:nBlocks
            rCondition=randperm(nConditions);
            for j=1:nConditions
                trial=trial+1;
                newlist(trial)=playList{exper}((i-1)*nConditions+rCondition(j));
            end
        end
        
        playList{exper}=newlist;
        nTrials(exper)=nItems;
         
    elseif strcmp(design,'Between')
        %Between: Every subject sees only one condition
        
        nItems=max([items{exper}(:).item]);
        nConditions=max([items{exper}(:).condition]);
        
        %Loop through items
        for i=1:nItems
            selectCondition=pList(exper);
            selectItem=i-1;
            index=selectItem*nConditions+selectCondition;
            playList{exper}(i)=items{exper}(index);
        end
        
        rTrial=randperm(nItems);
        newlist=items{exper}(1);
        for i=1:nItems
            newList(i)=playList{exper}(rTrial(i));
        end
        
        playList{exper}=newList;
        nTrials(exper)=nItems;
        
    elseif strcmp(design,'Blocked')
        %Blocked: Every subject sees all conditions, but in separate
        %consecutive blocks (blocks in random order)
        
        nItems=max([items{exper}(:).item]);
        nConditions=max([items{exper}(:).condition]);
        
        %Loop through items
        for j=1:nConditions
            selectCondition=mod(j+pList(exper)-1,nConditions)+1;
            for i=1:nItems
                selectItem=i;
                trial=(j-1)*nItems+i;
                index=selectItem*nConditions-selectCondition+1;
                playList{exper}(trial)=items{exper}(index);
            end
        end
        
        rCond=0;
        while rCond~=pList(exper)
            rCond=randperm(nConditions);
        end
        
        newlist=items{exper}(1);
        for j=1:nConditions
            selectCondition=rCond(j);
            rTrial=randperm(nItems);
            for i=1:nItems
                newTrial=(j-1)*nItems+i;
                trial=(selectCondition-1)*nItems+rTrial(i);
                newList(newTrial)=playList{exper}(trial);
            end
        end
        
        playList{exper}=newList;
        nTrials(exper)=nConditions*nItems;
        
    elseif strcmp(design,'BlockedFixed')
        
        nItems=max([items{exper}(:).item]);
        nConditions=max([items{exper}(:).condition]);
        
        %Loop through items
        for j=1:nConditions
            selectCondition=j;
            for i=1:nItems
                selectItem=i;
                trial=(j-1)*nItems+i;
                index=selectItem*nConditions-selectCondition+1;
                playList{exper}(trial)=items{exper}(index);
            end
        end
        
        rCond=0;
        while rCond~=pList(exper)
            rCond=randperm(nConditions);
        end
        
        newlist=items{exper}(1);
        for j=1:nConditions
            selectCondition=rCond(j);
            rTrial=randperm(nItems);
            for i=1:nItems
                newTrial=(j-1)*nItems+i;
                trial=(selectCondition-1)*nItems+rTrial(i);
                newList(newTrial)=playList{exper}(trial);
            end
        end
        
        playList{exper}=newList;
        nTrials(exper)=nConditions*nItems;
        
    else
        error(['design: ' num2str(design) 'is  unknown!'])
        
    end
    
    
end
