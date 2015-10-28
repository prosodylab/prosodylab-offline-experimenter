

function showSentence(ws, context, text, settings)
        
        %record_instructions=strcat(text,settings.message);
        %DrawFormattedText(ws.ptr,record_instructions, 'center','center', 0);
        while KbCheck([-1]); end; 
        
        DrawFormattedText(ws.ptr, double(context),50,300,0,settings.textwidth,[],[],1.2);
        
        DrawFormattedText(ws.ptr, double(text),50,500,0,settings.textwidth,[],[],1.2);
        
        Screen('DrawText', ws.ptr, double(settings.messageShow),50,600);
       
        Screen('Flip',ws.ptr);
    
        while ~KbCheck([-1]); end;
        %t=waitforbuttonpress;  %wait for mouse or key press
          
end
