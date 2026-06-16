clear; close all;

demo_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(fileparts(demo_dir));
run(fullfile(repo_root, 'matlab', 'startup.m'));

data_dir = fullfile(repo_root, 'examples', 'data');

img = imread(fullfile(data_dir, '1.png'));
blk_size = 16;
smooth_size = 16;
[ori, ~, roi] = ComputeDir(img, blk_size, smooth_size);

ori = imresize(ori, size(img), 'nearest');
mask = double(roi);
ori(mask == 0) = 91;

param.method_shape = 'Given';
param.method_of = 'Given';
param.h = size(img, 1);
param.w = size(img, 2);
param.DIR = ori;
param.mask = mask;

MINU = load_neu_mnt(fullfile(data_dir, 'mf1_mnt.mnt'));
I = ReconstructFingerprint(MINU, param); %#ok<NASGU>

function MINU = load_neu_mnt(fname)
data = textread(fname); %#ok<DTXTRD>
MINU = zeros(size(data, 1), 4);
MINU(:, 1:min(4, size(data, 2))) = data(:, 1:min(4, size(data, 2)));
MINU(:, 3) = 360 - MINU(:, 3);
end
