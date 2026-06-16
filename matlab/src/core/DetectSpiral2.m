function [MINU] = DetectSpiral2(P,DIR)
% more precise than DetectSpiral, considers phase inversion
% P must be normalized to (-pi,pi]
% Jianjiang Feng
% 2009-01

[h,w] = size(P);
dx = [-1 0 1 1 1 0 -1 -1 -1];
dy = [-1 -1 -1 0 1 1 1 0 -1];

mark = DetectSpiral2_precise_mex(P,DIR);

% % % Poincare index
% pts = [];
% mark = zeros(size(P));
% for m = 5:h-4
%     for n = 5:w-4
%         if P(m,n)>pi
%             continue
%         end
%         index = ComputeIndex(m,n);
%         mark(m,n) = index;
% %         if int32(index)==1
% %             mark(m,n) = 1;
% %         elseif int32(index)==-1
% %             mark(m,n) = -1;
% % %             pts(end+1,:) = [n m index];
% %         end
%     end
% end

% cluster
MINU1 = ClusterMinu(1);
MINU1(:,3) = NormalizeMinuDir(DIR(sub2ind([h w],MINU1(:,2),MINU1(:,1))));
MINU1(:,4)=1;
MINU2 = ClusterMinu(-1);
MINU2(:,3) = NormalizeMinuDir(DIR(sub2ind([h w],MINU2(:,2),MINU2(:,1)))+180);
MINU2(:,4)=-1;
MINU = [MINU1; MINU2];

%--------------------
function index = ComputeIndex2(r,c)
%
% Consider branch cuts in orientation field, more precisely, phase
% inversion, set the dir in the central block as reference to determine
% phase inversion in the 8 neighboring block
% 2017-04
idx = sub2ind(size(P),dy+r,dx+c);
p = P(idx);
dirs = DIR(idx);
if ~isempty(find(p>pi,1))% border
    index = 0;
else
    cdir = DIR(r,c);
    dd = abs(NormalizeMinuDir(dirs-cdir));
    if any(dd>90)% phase inversion happens
        invmask = dd>90;
        p(invmask) = -p(invmask);
    end
    dp = mod(diff(p),2*pi);
    dp(dp>pi) = dp(dp>pi)-2*pi;
    index = sum(dp)/(2*pi);
end
end

%--------------------
function index = ComputeIndex(r,c)
%
% Consider branch cuts in orientation field
% 2009-05
idx = sub2ind(size(P),dy+r,dx+c);
p = P(idx);
dirs = DIR(idx);
if ~isempty(find(p>pi,1))% border
    index = 0;
else
    dd = abs(NormalizeMinuDir(diff(dirs)));
    dp = mod(diff(p),2*pi);
    if ~isempty(find(dd>90,1))
        for i = 1:8
            if dd(i)>90
                dp(i) = p(i+1)+p(i);
            else
                dp(i) = p(i+1)-p(i);
            end
        end
    end
    dp = mod(dp,2*pi);
    dp(dp>pi) = dp(dp>pi)-2*pi;
    index = sum(dp)/(2*pi);
end
end



%--------------------
function index = ComputeIndex1(r,c)
%
idx = sub2ind(size(P),dy+r,dx+c);
p = P(idx);
if ~isempty(find(p>pi,1))% border
    index = 0;
else
    dp = mod(diff(p),2*pi);
    dp(dp>pi) = dp(dp>pi)-2*pi;
    index = sum(dp)/(2*pi);
end
index = round(index);

end



%--------------------
function minu = ClusterMinu(type) % assume minutiae of the same type can't be too close, if two minutiae near each other are detected, then keep one
%
radius = 1;
tmp_mark = mark==type;
tmp_mark = imdilate(tmp_mark,ones(2*radius+1));
X = bwlabel(tmp_mark,8);
num = max(X(:));
minu = zeros(num,4);
for i = 1:num
    [r,c] = find(X==i);
    idx = 1;
    if length(r)>1
        d = (r-mean(r)).^2+(c-mean(c)).^2;
        [val,idx] = min(d);
        mid = idx;
    end
    minu(i,:) = [c(idx) r(idx) type type];
end
end

%--------------------
function minu = ClusterMinu_old(type)
%
X = bwlabel(mark==type,8);
num = max(X(:));
minu = zeros(num,4);
for i = 1:num
    [r,c] = find(X==i);
    idx = 1;
    if length(r)>1
        d = (r-mean(r)).^2+(c-mean(c)).^2;
        [val,idx] = min(d);
        mid = idx;
    end
    minu(i,:) = [c(idx) r(idx) type type];
end
end

end
