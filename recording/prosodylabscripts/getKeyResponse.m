% chael@mcgill.ca

function [pressedkey resp_time]=getKeyResponse(acceptableKeys,timeLimit)

if nargin < 1
    acceptableKeys='all';
end
if nargin < 2
    timeLimit = inf;
end

start_time = GetSecs;

FlushEvents('keyDown');
 
keyIsDown=0;

while ~keyIsDown && GetSecs - start_time < timeLimit
    % check keyboard.
    [keyIsDown, end_time, keyCode] = KbCheck;
end

pressedkey = KbName(keyCode);

resp_time = end_time-start_time;

end