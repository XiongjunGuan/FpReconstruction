function D2 = FitHoleDir(D1,MASK)
% Fit the missed orientation elements in hole of the orientation field
%
% Parameters:
%   MASK:   0: background, 1: reliable block, 2: block to be fitted
%
% Jianjiang Feng
% 2009-02
D2 = D1;
[h,w] = size(D1);
D1 = D1*pi/180;
[r,c] = find(MASK==2);
dx = [-1 0 1 1 1 0 -1 -1];
dy = [-1 -1 -1 0 1 1 1 0];
ratio = zeros(1,8);
ratio(1:2:7) = 2;
ratio(2:2:8) = 1;
for k = 1:length(r)
    weight = 0;
    cosv = 0;
    sinv = 0;
    for m = 1:8
        lenx = w;
        if dx(m)>0
            lenx = w-c(k);
        elseif dx(m)<0
            lenx = c(k)-1;
        end
        leny = h;
        if dy(m)>0
            leny = h-r(k);
        elseif dy(m)<0
            leny = r(k)-1;
        end
        len = min(lenx,leny);
        r1 = r(k)+dy(m)*[1:len];
        c1 = c(k)+dx(m)*[1:len];
        idx1 = sub2ind([h w],r1,c1);
        idx2 = find(MASK(idx1)==1,1);
        if ~isempty(idx2)
            tempWeight = 1/(ratio(m)*idx2*idx2);
            weight = weight + tempWeight;
            cosv = cosv + tempWeight * cos(2*D1(idx1(idx2)));
            sinv = sinv + tempWeight * sin(2*D1(idx1(idx2)));
        end
    end
    D2(r(k),c(k)) = atan2(sinv,cosv)*90/pi;
end
