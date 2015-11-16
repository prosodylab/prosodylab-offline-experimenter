function ws = doScreen(settings)

try
	% screen stuff
  Screen('Preference', 'SkipSyncTests',1);
  Screen('Preference', 'Verbosity', 1); 
  screens=Screen('Screens');
  screenNumber=0; %max(screens);
  
  [ws.ptr, ws.rect] = Screen('OpenWindow',screenNumber);
  ws.center = [ws.rect(3) ws.rect(4)]/2;
  ws.black = BlackIndex(ws.ptr);
  ws.white = WhiteIndex(ws.ptr);
  ws.width = ws.rect(3);
  ws.halfw = ws.width;
  ws.height = ws.rect(4);
  ws.halfh = ws.height/2;
  
  % needed for drawdots
  %Screen('BlendFunction',ws.ptr,'GL_SRC_ALPHA','GL_ONE_MINUS_SRC_ALPHA');
  
	%Screen('TextFont',ws.ptr, 'Geneva');
	Screen('TextSize',ws.ptr, settings.textsize);
% 	Screen('FillRect', ws.ptr, ws.black);
  Screen('FillRect', ws.ptr, ws.white);
	Screen('Flip',ws.ptr);
	HideCursor;
catch
	cls;
end