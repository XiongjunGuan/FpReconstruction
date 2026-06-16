function Y = SmoothPhase(X,sigma)
%
cosv = cos(X);
sinv = sin(X);

radius = round(3*sigma);

g = fspecial('Gaussian',1+2*radius,sigma);
cosv = imfilter(cosv,g);
sinv = imfilter(sinv,g);
Y = atan2(sinv,cosv);
% Y(Y<0) = Y(Y<0)+2*pi;