function X = NormalizeMinuDir(X)
% Convert an angle to the range of (-180,180]
%
% Jianjiang Feng
% 2007-3

X = mod(X,360);
idx = find(X>180);
X(idx) = X(idx)-360;
