%Set experiment settings

function [settings]= settings()
     

    % additional column names
    settings.additionalColNames={'participant','playlist','order','trialN'};

    % space between lines in instruction
    settings.linespace=30;
    % fontsize
    settings.textsize = 2
    % textwidth
    settings.textwidth = 120;

    %
    % Messages to the Participant
    %

    % you can translate these messges in to Korean. Please leave the commented lines in English, 
    % so I know which line is which!

    %settings.message ='Read silently. Press any key when you''re ready for the dialogue.';
    settings.message ='Please read the last line carefully click any key when you''re ready to record!'; 
    settings.message2 ='Please say the last line out loud now. Press any key when you''re done recording!';
    settings.message3 ='Press any key when you''re ready for the next set of instructions!';
    settings.message4 ='Press any key when you''re ready for the next set of instructions!';
    settings.messageShow='Read silently and make sure you understand the sentences.';
    
    %settings.messageThankYou='Thank You!';
    settings.messageThankYou='Thank You!';
    
    settings.messageheight=400;
    
    %
    % Audio Settings
    %
    
    %

    
    %Input device
    % You can check which output devices there are
    % by using the command
    % devices = PsychPortAudio('GetDevices')
    %(unnecessary to worry about if you don't want to record sounds)
    %default outputdevice: use ''
    %(unnecessary to worry about if you don't want to play sounds)
    settings.outputdevice=0;
    settings.inputdevice=3;
    
    settings.sampfreq=22050;
    settings.maxsecs=300;
    settings.voicetrigger=0;
   
    % unify key names across operating systems
    KbName('UnifyKeyNames');

    settings.viewing_interval = 2; % in seconds, so .4 = 400ms
    settings.isi = 1; % inter stimulus interval
 
    settings.before_trial_interval = .5;
    settings.before_prompt_interval = 0;
    settings.trial_time_limit = 300;
    settings.experiment_time_limit = 600;
    settings.num_digits = 2;
    settings.max_addends = 8;
    
    settings.acceptedkeys = {'1!','2@','3#','4$','5%','6^','7&','8*','9(','0)',...
    'RETURN','DELETE','ESCAPE','ENTER','1','2','3','4','5','6','7',...
    '8','9','0'};

        
end  
        