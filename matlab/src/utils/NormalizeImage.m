function Y = NormalizeImage(X)
%
%
% Jianjiang Feng
% 2010-03
a = min(X(:));
b = max(X(:));
Y = (X-a)/(b-a);