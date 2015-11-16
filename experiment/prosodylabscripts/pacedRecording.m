function [recordedaudio, trigger, text]=pacedRecording(chunks, settings, screen)

samplingrate=settings.samplingFrequency;
voicetrigger=settings.voiceTrigger;
maxsecs=settings.maxsecs;

AssertOpenGL;

% Wait for release of all keys on keyboard:
while KbCheck([-1]); end;

InitializePsychSound;

% Basic initialization  sound driver:

pahandle = PsychPortAudio('Open', [settings.inputdevice], 2, 0, samplingrate, 1);

% Preallocate an internal audio recording  buffer with a capacity of 10 seconds:
PsychPortAudio('GetAudioData', pahandle, 10);

[~,nSegments]=size(chunks);

text=[];

recordedaudio = [];


% Start audio capture immediately and wait for the capture to start.
% We set the number of 'repetitions' to zero,
% i.e. record until recording is manually stopped.

WaitSecs(0.01);

% get beginning time of recording
tic;

PsychPortAudio('Start', pahandle, 0, 0, 1);

for i=1:nSegments
    
    text=[text chunks{i} ' '];
    
    DrawFormattedText(screen.ptr, double(settings.message2),settings.messagex,settings.messagey,[255, 0, 0, 255],settings.textwidth,[],[],1.2);
    DrawFormattedText(screen.ptr, double(text),settings.textx,settings.texty,0,settings.textwidth,[],[],1.2);
    Screen('Flip',screen.ptr);
    
    % Want to start via VoiceTrigger?
    if voicetrigger > 0
        % Yes. Fetch audio data and check against threshold:
        level = 0;
        
        % Repeat as long as below trigger-threshold:
        while level < voicetrigger
            % Fetch current audiodata:
            audiodata = PsychPortAudio('GetAudioData', pahandle);
            recordedaudio = [recordedaudio audiodata];
            
            % Compute maximum signal amplitude in this chunk of data:
            if ~isempty(audiodata)
                level = max(abs(audiodata(1,:)));
            else
                level = 0;
            end
            
            % Below trigger-threshold?
            if level < voicetrigger
                % Wait before next scan:
                WaitSecs(0.0001);
            end
        end
        
        trigger=toc;
        
        % how long to wait after utterance initiation to revela next segmetn
        WaitSecs(settings.paceDelay);
    end
    
end


% Stay in a little loop until keypress:
while ~KbCheck([-1]) & ((length(recordedaudio) / samplingrate) < maxsecs & ~isempty(screen) )
    
    % Retrieve pending audio data from the drivers internal ringbuffer:
    audiodata = PsychPortAudio('GetAudioData', pahandle);
    recordedaudio = [recordedaudio audiodata]; 
end


% We retrieve status once to get access to SampleRate:
s = PsychPortAudio('GetStatus', pahandle);

%add some time to the end of the recording
WaitSecs(0.1);

% Stop capture:
PsychPortAudio('Stop', pahandle);

% Perform a last fetch operation to get all remaining data from the capture engine:
audiodata = PsychPortAudio('GetAudioData', pahandle);

% Attach it to our full sound vector:
recordedaudio = [recordedaudio audiodata];



% Close the audio device:
PsychPortAudio('Close', pahandle);

end
