% presents text and waits for keypress
% ws : screen
% text: sentence to be displayed

function askReady(ws,text,settings)
        
        %DrawFormattedText(ws.ptr,text,'center','center',0);
        Screen('DrawText', ws.ptr, double(text),100,settings.messagey);
        
        while KbCheck([-1]); end; 
        Screen('Flip',ws.ptr);
        while ~KbCheck([-1]); end; 
        %t=waitforbuttonpress;  %wait for mouse or key press
end
