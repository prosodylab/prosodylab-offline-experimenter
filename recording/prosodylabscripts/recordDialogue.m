

function recordDialogue(contextFile, ws, context, text, wavfilename, labfilename,settings)

        settings.trial_time_limit=10;
        
        %record_instructions=strcat(dialogue,message);
        %DrawFormattedText(ws.ptr,record_instructions, 'center','center', 0);
         while KbCheck([-1]); end;
            Screen('DrawText', ws.ptr, double(context),50,[settings.messageheight-400]);
            Screen('DrawText', ws.ptr, double(text{1}),50,[settings.messageheight-200]);
            Screen('DrawText', ws.ptr, double(text{2}),50,[settings.messageheight-150],[1 0 0]);
            Screen('DrawText', ws.ptr, double(settings.message),50,settings.messageheight);
       
            Screen('Flip',ws.ptr);

        while ~KbCheck([-1]); end;
        %t=waitforbuttonpress;  %wait for mouse or key press
       
        RecordSound(contextFile, context, wavfilename,settings,1,ws,text);  
        
        %Save .lab file        
        fid = fopen([labfilename],'a');  %open file and appending
        fprintf(fid,'%s\n',text{2});  %print item text to file
        fclose(fid);  %close file    
end