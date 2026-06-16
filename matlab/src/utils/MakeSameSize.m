function Y = MakeSameSize(X,h1,w1,fillval)
% MakeSameSize - Image size is not exactly same after minify and magnify,
% so modify it
%
% Jianjiang Feng
% 2008-04

Y = X;
[h2,w2] = size(X);
if h2>h1
    Y = Y(1:h1,:);
elseif h2<h1
    rows = h1-h2;
    Y = [Y; fillval*ones(rows,w2)];
end

if w2>w1
    Y = Y(:,1:w1);
elseif w2<w1
    cols = w1-w2;
    Y = [Y fillval*ones(h1,cols)];
end
