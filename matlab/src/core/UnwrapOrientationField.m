function [D2,mask,xnn,ynn,sps] = UnwrapOrientationField(D1,bShow)
% Unwrap orientation field
%
% Jianjiang Feng
% 2009-02
if exist('bShow','var')==0
    bShow = 0;
end
copy_D1 = D1;
D1 = 91*ones(size(D1)+2);
D1(2:end-1,2:end-1) = copy_D1;

% constants
dx = [0 1 0 -1]; dy = [-1 0 1 0];

[h,w] = size(D1);

% % set border as invalid
% D1(:,[1 w]) = 91;
% D1([1 h],:) = 91;

% Fill hole (not connected to border)
MASK = FillHole(D1~=91);
D1 = FitHoleDir(D1,MASK);

% detect singular points
sps = DetectSP(D1, D1~=91, 2, 1);
if bShow && ~isempty(sps)
    %     DrawDir(figNum,D1,1,'k2');
    %     DrawSPNoDir(1,sps(:,[1 2 7]));
    %     DrawSP(figNum,sps,'rr');
end

% Find branch cuts
[xnn,ynn] = GetBranchCuts(D1,sps);
if ~isempty(xnn)
    xn = xnn{end};
    yn = ynn{end};
else
    xn = [];yn = [];
end
if bShow
    plot(xn(1:end),yn(1:end),'k.')
end



MASK = D1~=91;
INVMASK = ~MASK;
distmap = bwdist(INVMASK);
[vals,idx] = sort(distmap(:),'descend');
[yy,xx] = ind2sub(size(distmap),idx(vals>0));

%
FLAG = zeros(size(D1)); % 0 background, 1 foreground, 2 branch cuts, 3 in queue and unwrapped
FLAG(D1~=91) = 1;
FLAG(sub2ind([h w],yn,xn)) = 2;
mask=FLAG(2:end-1,2:end-1);
% % set border as invalid
% mask(:,[1 end]) = 0;
% mask([1 end],:) = 0;
% Iterative unwrap
D2 = D1;
for ii = 1:length(yy)
    y = yy(ii);
    x = xx(ii);
    if FLAG(y,x)~=1
        continue
    end
    % Keep orientation unchanged
    D2(y,x) = D1(y,x);
    FLAG(y,x) = 3;% Change flag
    q = zeros(h*w,2);
    q(1,:) = [x y];% push into queue
    qid = 1; qlen = 1;
    while qid<=qlen
        x1 = q(qid,1); y1 = q(qid,2);
        qid = qid + 1;
        for k = 1:4
            x2 = x1 + dx(k); y2 = y1 + dy(k);
            if FLAG(y2,x2)==1
                % Upwrap, change flag and push into queue
                dif = D2(y1,x1)-D1(y2,x2);
                D2(y2,x2) = D1(y2,x2) + round(dif/180)*180;
                FLAG(y2,x2) = 3;
                qlen = qlen + 1;
                q(qlen,1:2) = [x2 y2];
            end
        end
    end
end


% % Unwrap branch cuts
% % TODO: if a branch cut is thick, iterative unwrap is needed.
% for i = 1:length(xn)
%     x1 = xn(i); y1 = yn(i);
%     for k = 1:4
%         x2 = x1 + dx(k); y2 = y1 + dy(k);
%         if x2<1 || x2>w || y2<1 || y2>h
%             continue
%         end
%         if FLAG(y2,x2)==3
%             dif = D2(y2,x2)-D1(y1,x1);
%             D2(y1,x1) = D1(y1,x1) + round(dif/180)*180;
%             FLAG(y2,x2) = 4;% Do not use unwrapped branch cut to unwrap
%             break
%         end
%     end
% end



if ~isempty(xnn)
    
    % Unwrap branch cuts
    % TODO: if a branch cut is thick, iterative unwrap is needed.
    
    
    for i = 1:length(xnn)-1
        cxn = xnn{i};
        cyn = ynn{i};
        start = round(length(cxn)/2);
        for j = start+1:length(cxn)
            dif = D2(cyn(j),cxn(j)) - D2(cyn(j-1),cxn(j-1));
            if abs(mod(dif,360)-180)<90
                D2(cyn(j),cxn(j)) = D2(cyn(j),cxn(j)) - sign(dif)*180;
            end
        end
        for j = start-1:-1:1
            dif = D2(cyn(j),cxn(j)) - D2(cyn(j+1),cxn(j+1));
            if abs(mod(dif,360)-180)<90
                D2(cyn(j),cxn(j)) = D2(cyn(j),cxn(j)) - sign(dif)*180;
            end
        end
    end
    
    % % for each branch cut, there should be another one along with the
    % original one, which has a 180 degree difference, together, they form the
    % border of branch cut
    xnn(end)=[];
    ynn(end)=[];
    ll = length(xnn);
    fail_ind = [];
    for i = 1:ll
        cx = xnn{i};
        cy = ynn{i};
        
        
        %             figure;imshow(D2,[]);
        %             hold on;line(cx,cy,'color','r');
        % extend the front and end of the line by 1 pixel
        ecx = [cx(1)+cx(1)-cx(2), cx, cx(end)+cx(end)-cx(end-1)]; ecx = ecx(:);
        ecy = [cy(1)+cy(1)-cy(2), cy, cy(end)+cy(end)-cy(end-1)]; ecy = ecy(:);
        
        im = false(size(D2));
        im(sub2ind(size(D2),cy,cx)) = true;
        im=imdilate(im,ones(3));
        ind1 = find(im);
        tmpmask = ecx>=1 & ecx<=w & ecy>=1 & ecy<=h;
        ind2 = setdiff(ind1,sub2ind(size(D2),ecy(tmpmask),ecx(tmpmask)));
        im = false(size(D2));
        im(ind2) = true;
        tmpmask = true(size(D2));
        tmpmask(2:end-1,2:end-1) = 0;
        im(tmpmask) = 0;
        [I,cnt] = bwlabel(im,4);
        if cnt==1
            fail_ind = [fail_ind,i];
            continue;
        end
        ind1 = I==1;
        ind2 = I==2;
        I = ones(size(D2));
        I(ind1) = 0;
        ind1 = FindCurve2(I,cx(1),cy(1));
        I = ones(size(D2));
        I(ind2) = 0;
        ind2 = FindCurve2(I,cx(1),cy(1));
        
        y=ind1(2,round((1+size(ind1,2))/2));
        x=ind1(1,round((1+size(ind1,2))/2));
        flag = 0;
        dx2 = [0 1 0 -1 1 1 -1 -1]; dy2 = [-1 0 1 0 1 -1 1 -1];
        for k = 1:8
            xx = dx2(k) + x;
            yy = dy2(k) + y;
            if xx<1 || xx>w || yy<1 || yy>h
                continue;
            end
            if D2(yy,xx)==91
                continue;
            end
            if abs(mod(D2(y,x)-D2(yy,xx),360)-180) < 50
                flag = 1;
                break;
            end
        end
        if flag==1
            xnn{end+1} = ind1(1,:);
            ynn{end+1} = ind1(2,:);
        else
            xnn{end+1} = ind2(1,:);
            ynn{end+1} = ind2(2,:);
        end
        %     hold on;line(xnn{end},ynn{end},'color','g');
    end
    xnn(fail_ind) = [];
    ynn(fail_ind) = [];
    xnn{end+1}=[];
    ynn{end+1}=[];
    for i = 1:length(xnn)-1
        xnn{end} = [xnn{end}, xnn{i}];
        ynn{end} = [ynn{end}, ynn{i}];
    end
    
    
    D2(D1==91) = 1000;% invalid value
    D2 = D2(2:end-1,2:end-1);
    for i = 1:length(xnn)
        for j = 1:length(xnn{i})
            xnn{i}(j) = xnn{i}(j)-1;
            ynn{i}(j) = ynn{i}(j)-1;
        end
    end
else
    D2(D1==91) = 1000;% invalid value
    D2 = D2(2:end-1,2:end-1);
end


    

