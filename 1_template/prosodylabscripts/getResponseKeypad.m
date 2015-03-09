% courtesy EV
% rewritten for better dynamics MCF 10/10/08
% this version has worse timing but reads in from GetChar so that it can
% use external keyboards

function [pressedkey resp_time]=getResponseKeypad(willTake,varargin)

if nargin > 1
  time_limit = varargin{1};
else
  time_limit = Inf;
end

start_time = GetSecs;

FlushEvents('keyDown');

goodkeydown = 0;

key = 'NONE';
while ~goodkeydown && GetSecs - start_time < time_limit
  
  if CharAvail
    key = GetChar;
  end
   %fprintf('%d',char(key))
  
  if ~strcmp(willTake,'all') % the specific key option
    if any(strcmp(willTake,key)) 
      pressedkey = key;
      goodkeydown = 1;
    end

  elseif ~strcmp(key,'NONE') % the ANY key option
    goodkeydown = 1;
    disp(key)
    key = 'ANY';
  end
end

if ~exist('pressedkey')
  pressedkey = 'NONE';
end
end_time=GetSecs;
resp_time=end_time-start_time;