%Set experiment settings

function [settings]= settings()
     

    % additional column names
    settings.additionalColNames={'participant','language','playlist','order','trialN'};

    % space between lines in instruction
    settings.linespace=30;
    
    % fontsize
    settings.textsize = 20;
    
    % textwidth
    settings.textwidth = 120;

    %
    % Messages to the Participant
    %

    % you can translate these messges in to Korean. Please leave the commented lines in English, 
    % so I know which line is which!

    %settings.message ='Read silently. Press any key when you''re ready for the dialogue.';
    settings.message ='Press any key to hear the question.';
    
    %settings.message2 ='Listen to the other person, then answer as naturally as possible. Press any key when you're done!';
    settings.message2 ='Now, say your answer. Press any key when you''re done recording!';
    
    %settings.message3 ='Press any key when you''re ready for the next dialogue!';
    settings.message3 ='Press any key when you''re ready to continue!';
    
    settings.messageShow='Read silently and make sure you understand the sentence.';
    
    %settings.messageThankYou='Thank You!';
    settings.messageThankYou='Thank You!';
    
    %settings.message4 ='Yes=1  No=0';
    settings.message4 ='Yes=1  No=0';
    
    settings.messageheight=400;
    
    %
    % Audio Settings
    %
    
    %
    %default outputdevice: use ''
    %(unnecessary to worry about if you don't want to play sounds)
    settings.outputdevice=5;
    
    %Input device
    % You can check which output devices there are
    % by using the command
    % devices = PsychPortAudio('GetDevices')
    %(unnecessary to worry about if you don't want to record sounds)
    settings.inputdevice=5;
    
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

    %settings.acceptedkeys ='all';
        
end  
        