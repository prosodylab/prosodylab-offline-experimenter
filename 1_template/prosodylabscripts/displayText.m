
function displayText(ws,text,y,settings)
    % Display Instructions
    %text=native2unicode(text,'UTF-8');
    Screen('TextSize',ws.ptr,settings.textsize);
    Screen('DrawText', ws.ptr, double(text),50,y);
   
    Screen('Flip',ws.ptr);
end