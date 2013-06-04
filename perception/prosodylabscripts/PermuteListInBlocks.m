% PermuteListInBlocks
% chael@mcgill.ca 11/17/09

%%Inputs
% playList : unrandomized structure of trials
% blocksize: size of blocks that are to be randomized 
% (e.g., number of conditions)

%Outputs:
% randomized playLIst

function [newList]=PermuteListInBlocks(playList,nSets,blockSize)

[~,nTrials]=size(playList);


setSize=nTrials/(nSets*blockSize);


if blockSize==1&&nSets==1
    rand_index = randperm(nTrials);
    
    for i=1:nTrials
        newList(i)=playList(rand_index(i));
    end
    
elseif nTrials/(nSets*blockSize)~=round(nTrials/(nSets*blockSize))
    disp('Number of trials in list not divisible by number of blocks');
    
else

    randSet=randperm(nSets);
    for k=1:nSets
    randBlocks=randperm(setSize);
    for i=1:setSize
        randIndex=randperm(blockSize);
        for j=1:blockSize
            line=setSize*blockSize*(k-1)+blockSize*(i-1)+j;
            choice=setSize*(randSet(k)-1)+blockSize*(randBlocks(i)-1)+randIndex(j);
            newList(line)=playList(choice);       
        end
    end
    
end
 
end

end