function [val, num] = howmany(x)

% [val, num] = howmany(x)
%
% counts the number of occurrences of finite values in x
%
%  in:  x    vector of nnumbers (array will be reshaped to a vector)
%
% out: val   unique values in x, sorted
%      num   number of occurrences

% Pekka Kumpulainen 17.8.2005

x = x(:);
x = x(isfinite(x));
sx = sort(x);

difsx = diff(sx);
fdx = [0;find(difsx>0);length(sx)];
num = diff(fdx);

ifx = find([1;difsx]);
val = sx(ifx);

