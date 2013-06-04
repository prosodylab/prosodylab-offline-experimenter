
function displayTextKey(ws,text,settings)
    % Display Instructions
    text=native2unicode(text,'UTF-8');
    Screen('TextSize',ws.ptr,settings.textsize);
    Screen('DrawText', ws.ptr, double(text));
    
     while KbCheck([-1]); end; 
     Screen('Flip',ws.ptr);
     while ~KbCheck([-1]); end; 
end