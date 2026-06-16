function I = ReconstructFingerprint(MINU,param)
% ReconstructFingerprint_Smooth
%
% Input:
% - MINU:[n, 3+], first 3 col are x, y, theta
% - param: settings

bDebug = 0;
blksize = 8;% at most 8
f = 0.1;


% param.method_shape = 'Conv';
% param.method_of = 'Minu';
% param.h = max(MINU(:,2));
% param.w = max(MINU(:,1));

h = param.h; w = param.w;
bh = ceil(h/blksize);
bw = ceil(w/blksize);
h = bh*blksize;
w = bw*blksize;

MINU = round(MINU);

%% Estimate foreground
% mask has block of 8x8
if strcmp(param.method_shape,'Conv')
    K = convhull(MINU(:,1),MINU(:,2));
    mask = poly2mask(MINU(K,1),MINU(K,2),h,w);
%     Show(2,1-mask);
    se = strel('disk',32);
    mask = imdilate(mask, se);
elseif strcmp(param.method_shape,'Given')
    mask = param.mask;
    mask = MakeSameSize(mask,h,w,0);
end

%% Reconstruct orientation field
if strcmp(param.method_of,'Given')
    DIRp1 = double(param.DIR);
    DIRp1 = MakeSameSize(DIRp1,h,w,91);
    DIRp1(DIRp1>91) = DIRp1(DIRp1>91)-256;
    DIRb1 = DIRp1(blksize/2:blksize:end,blksize/2:blksize:end);
    DIRp2 = UnwrapOrientationField(DIRp1);
elseif strcmp(param.method_of,'Minu')
    DIRb1 = ReconstructDir(mask(blksize/2:blksize:end,blksize/2:blksize:end),blksize,MINU,'Near');
    DIRp1 = ResizeDirImage(DIRb1,blksize);% 2009-11
%     DIRp1 = imresize(DIRb1,blksize,'nearest');
    DIRp2 = UnwrapOrientationField(DIRp1);
end

if bDebug
    Show(1,ones(h,w));
    DrawMinu(1,MINU,'kk');
    Show(2,1-mask);
    Show(3,ones(h,w));
    DrawDir(3,DIRb1(1:2:end,1:2:end),blksize*2,'k2');
end

[X,Y] = meshgrid(1:w,1:h);

%% Generate fingerprint by iterative Gabor filtering
border = 15;
I_initial = randn(h+2*border,w+2*border);
F = f*ones(h,w);%.*(1+0.4*(rand(h,w)-0.5));
F(~mask) = 0;
F_temp = zeros(size(I_initial));
F_temp(border+1:end-border,border+1:end-border) = F;
DIR2 = NormalizeMinuDir(-DIRp2);
DIR_temp = zeros(size(I_initial));
DIR_temp(border+1:end-border,border+1:end-border) = DIR2;
for k = 1:5
    I_initial = ridgefilterOriginal(I_initial, DIR_temp*pi/180, F_temp, 0.5, 0.5, 0);
    I_initial = NormalizeImage(I_initial);
end
Ir = ridgefilterComplex(I_initial, DIR_temp*pi/180, F_temp, 0.5, 0.5, 0, 1);
Ii = ridgefilterComplex(I_initial, DIR_temp*pi/180, F_temp, 0.5, 0.5, 0, 0);
Im = sqrt(Ir.^2 + Ii.^2);
P_initial = atan2(Ii,Ir);
P_initial(Im<0.00001) = 2*pi;% invalid
P_initial = P_initial(border+1:end-border,border+1:end-border);
MINU2 = DetectSpiral2(P_initial,DIRp2);
MINU2_idx = sub2ind(size(P_initial),MINU2(:,2),MINU2(:,1));
MINU2_polarity = double(abs(NormalizeMinuDir(MINU2(:,3)-DIRp2(MINU2_idx)))<=90);
MINU2_polarity = MINU2_polarity*2-1; % 1->1; 0->-1
if bDebug
    Show(4,I_initial(border+1:end-border,border+1:end-border),'Initial Image');
    Show(5,I_initial(border+1:end-border,border+1:end-border),'Initial Image Real');
    Show(6,I_initial(border+1:end-border,border+1:end-border),'Initial Image Imag');
    Show(7,P_initial,'Initial Image Phase');
%     I_initial = (cos(P_initial)+1)/2;
%     Show(5,I_initial,'Initial Fingerprint');
    DrawMinu(7,MINU2,'b');
end

%% Remove minutiae
[X,Y] = meshgrid(1:w,1:h);
PM = zeros(h,w);
for k = 1:size(MINU2,1)
    PM = PM+MINU2_polarity(k)*atan2(Y-MINU2(k,2),X-MINU2(k,1));
end
PM(P_initial>pi) = 0;
P_initial_continuous1 = P_initial - PM;
P_initial_continuous = SmoothPhase(P_initial_continuous1,2);
P_initial_continuous(P_initial>pi) = 2*pi;
if bDebug
%     Show(5,(1+cos(P_initial_continuous1))/2);
    Show(8,PM);
%     Show(9,(1+cos(P_initial_continuous))/2);
    Show(9,P_initial_continuous);
end

%% spiral phase
mphi = ones(h,w)*2*pi;
for m = 1:size(MINU,1)
    % determine flag of minutia
    if abs(NormalizeMinuDir(MINU(m,3)-DIRp2(MINU(m,2),MINU(m,1))))>90
        flag = -1;
    else
        flag = 1;
    end
    mphi = mphi+flag*atan2(Y-MINU(m,2),X-MINU(m,1));
end

phi = P_initial_continuous + mphi;
phi(P_initial>pi) = 2*pi;
I = (cos(phi)+1)/2;
if bDebug
    mphi2 = mod(mphi,2*pi);
    mphi2(mphi2>pi) = mphi2(mphi2>pi)-2*pi;
    mphi2(P_initial>pi) = pi;
    Show(10,mphi2);
    Show(11,I,'Reconstructed fingerprint');
end
I = I(1:param.h,1:param.w);

