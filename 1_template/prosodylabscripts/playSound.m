function [t1 offset]=playSound(soundFile,settings)

AssertOpenGL;
InitializePsychSound;

% read in context file
[y, freq, nbits] = wavread(soundFile);
wavedata = y';
nrchannels = size(wavedata,1);
duration=size(wavedata,2)/freq;

% Basic initialization sound driver:
pahandle = PsychPortAudio('Open', [settings.outputdevice], [1], 0, freq, nrchannels);

% Fill audio playback buffer with audio data
% 'wavedata':
PsychPortAudio('FillBuffer', pahandle, wavedata);

% Start audio playback for 'repetitions' repetitions of the sound data,
% start it immediately (0) and wait for the playback to start, return onset
% timestamp.
t1 = PsychPortAudio('Start', pahandle, 1, 0, 1);

% Play sound
WaitSecs(duration);
offset=GetSecs;

% Stop playback:
PsychPortAudio('Stop', pahandle);

% Close the audio device:
PsychPortAudio('Close', pahandle);