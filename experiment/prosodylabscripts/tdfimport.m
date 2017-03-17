% tdfimport

% imports tab-delimited file into data structure
% and returns data structure and an array with the column names
% chael@mcgill.ca 11/17/09

function [items, columnNames] = tdfimport(file_name)

%Retrieve items

fid = fopen(file_name,'r', 'l', 'UTF-8');

if fid==-1
    error('Experimentfile file was not found, please verify file name');
end

columnNames = strcat(fgetl(fid));
%columnNames = textscan(columnNames, '%s','delimiter','\t','BufSize',16384);

columnNames = strsplit(columnNames,'\t');
[a nCol]=size(columnNames);

nTrials=0;
items=[];
line=0;

while line ~= -1
  
    % get next line from text file
    line = fgetl(fid);
    
    % if there was another line in the text file
    if line ~= -1
        
         nTrials=nTrials+1;
       
         % parse line of textfile into cells
         content = strsplit(line,'\t');

         % store how many cells were in this line
         [a nCells]=size(content);
         
         % cycle through all columns
         for i=1:nCol
             
             % this makes script compatible with lines that are shorter
             % than others
             if i <= nCells
                % store cell number into variable
                items(nTrials).(genvarname(columnNames{i}))=content{i};
             else
                items(nTrials).(genvarname(columnNames{i}))=[];
             end
         end
    end
end

% convert certain columns to numbers
lengthItems=length(items);
for i=1:lengthItems
    items(i).condition=str2double(items(i).condition);
    items(i).item=str2double(items(i).item);
    if isfield(items, 'session')
        items(i).session=str2double(items(i).session);
    end
    if isfield(items, 'nChoices')
        items(i).nChoices=str2double(items(i).nChoices);
    end
    if isfield(items, 'experimentTrial')
        items(i).experimentTrial=str2double(items(i).experimentTrial);
    end
end


fclose(fid);
 
end


