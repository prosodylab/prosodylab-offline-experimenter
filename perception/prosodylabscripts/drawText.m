% scwrite.m
% Michael Frank
% 
% scwrite(text, window, center, wait [, delay])
% Writes to screen center and waits to go on for delay if wait = 0.
% If wait = 1, waits for a key to be pressed.

function drawText(text,ws,wait,varargin)

if nargin > 3
  delay = varargin{1};
else
  delay = 0;
end;

if nargin > 4
  color = varargin{2};
else
  color = ws.black;
end

Screen('Flip',ws.ptr);
% Screen('TextSize',ws.ptr,32);
[x,y] = Screen('TextBounds',ws.ptr,text);
Screen('DrawText',ws.ptr,text,ws.center(1)-(x(3)/2),ws.center(2),color);
Screen('Flip',ws.ptr);

if wait == 1
  getResponseKeypad('all');
else
  WaitSecs(delay);
end;


