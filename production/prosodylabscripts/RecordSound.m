function [recordedaudio]=RecordSound(contextFile, context, text, imdata, display, screen, settings)

samplingrate=settings.sampfreq;
voicetrigger=settings.voicetrigger;
maxsecs=settings.maxsecs;

AssertOpenGL;

% Wait for release of all keys on keyboard:
while KbCheck([-1]); end;



InitializePsychSound;

% show text and context if 'display' is set to true

if ~isempty(screen)
    
    if display
        DrawFormattedText(screen.ptr, double(settings.message2),50,300,0,settings.textwidth,[],[],1.2);
        
        DrawFormattedText(screen.ptr, double(context),50,400,0,settings.textwidth,[],[],1.2);
        
        DrawFormattedText(screen.ptr, double(text),50,750,0,settings.textwidth,[],[],1.2);
        
        Screen(screen.ptr,'PutImage',imdata,[100 500 300 700]) ;
        
        Screen('Flip',screen.ptr);
        

    else
        Screen('DrawText', screen.ptr, double(settings.message2),50,[settings.messageheight]);
        Screen('Flip',screen.ptr);
    end
end

% play contextFile if there is one

if ~isempty(contextFile)
    % read in context file
    [y, freq, nbits] = wavread(contextFile);
    wavedata = y';
    nrchannels = size(wavedata,1);
    duration=size(wavedata,2)/freq;
    
    % Basic initialization  sound driver:
    
    pahandle = PsychPortAudio('Open', [settings.outputdevice], [1], 0, freq, nrchannels);
    
    % Fill the audio playback buffer with the audio data 'wavedata':
    PsychPortAudio('FillBuffer', pahandle, wavedata);
    
    % Start audio playback for 'repetitions' repetitions of the sound data,
    % start it immediately (0) and wait for the playback to start, return onset
    % timestamp.
    t1 = PsychPortAudio('Start', pahandle, 1, 0, 1);
    
    WaitSecs(duration);
    
    % Stop playback:
    PsychPortAudio('Stop', pahandle);
    
    % Close the audio device:
    PsychPortAudio('Close', pahandle);
end

% Basic initialization  sound driver:

pahandle = PsychPortAudio('Open', [settings.inputdevice], 2, 0, samplingrate, 1);

% Preallocate an internal audio recording  buffer with a capacity of 10 seconds:
PsychPortAudio('GetAudioData', pahandle, 10);

% Start audio capture immediately and wait for the capture to start.
% We set the number of 'repetitions' to zero,
% i.e. record until recording is manually stopped.
PsychPortAudio('Start', pahandle, 0, 0, 1);

% Want to start via VoiceTrigger?
if voicetrigger > 0
    % Yes. Fetch audio data and check against threshold:
    level = 0;
    
    % Repeat as long as below trigger-threshold:
    while level < voicetrigger
        % Fetch current audiodata:
        [audiodata offset overflow tCaptureStart] = PsychPortAudio('GetAudioData', pahandle);
        
        % Compute maximum signal amplitude in this chunk of data:
        if ~isempty(audiodata)
            level = max(abs(audiodata(1,:)));
        else
            level = 0;
        end
        
        % Below trigger-threshold?
        if level < voicetrigger
            % Wait for a millisecond before next scan:
            WaitSecs(0.0001);
        end
    end
    
    % Ok, last fetched chunk was above threshold!
    % Find exact location of first above threshold sample.
    idx = min(find(abs(audiodata(1,:)) >= voicetrigger)); %#ok<MXFND>
    
    % Initialize our recordedaudio vector with captured data starting from
    % triggersample:
    recordedaudio = audiodata(:, idx:end);
else
    % Start with empty sound vector:
    recordedaudio = [];
end

% We retrieve status once to get access to SampleRate:
s = PsychPortAudio('GetStatus', pahandle);

% Stay in a little loop until keypress:
while ~KbCheck([-1]) & ((length(recordedaudio) / samplingrate) < maxsecs & ~isempty(screen) )
    
    % Retrieve pending audio data from the drivers internal ringbuffer:
    audiodata = PsychPortAudio('GetAudioData', pahandle);
    recordedaudio = [recordedaudio audiodata]; %#ok<AGROW>
end

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

