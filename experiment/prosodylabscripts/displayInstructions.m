
function displayInstructions(ws,filename,settings)

Screen('TextSize',ws.ptr,settings.textsize);


fid = fopen(filename,'r', 'l', 'UTF-8');

if fid==-1
    error('Instructions file was not found, please verify file name');
end

linecounter=0;
line=0;

while ~feof(fid)
  
    % get next line from text file
    line = fgetl(fid);
    
    % if there was another line in the text file
    if line ~= -1
        
        linecounter=linecounter+1;
        text=native2unicode(line,'UTF-8');
 
        y=50+(linecounter*settings.linespace);
        Screen('DrawText', ws.ptr, double(text),15,y);
    else
        linecounter=linecounter+1;
    end
end

fclose(fid);

% Wait for keypress
while KbCheck([-1]); end;
Screen('Flip',ws.ptr);
while ~KbCheck([-1]); end;

end