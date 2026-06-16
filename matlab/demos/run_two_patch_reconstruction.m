clear; close all;

demo_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(fileparts(demo_dir));
run(fullfile(repo_root, 'matlab', 'startup.m'));

sample_dir = fullfile(repo_root, 'examples', 'data', '1');

[ori1, mask1, img1] = extract_feature(fullfile(sample_dir, 'img', '1.png'));
[ori2, mask2, img2] = extract_feature(fullfile(sample_dir, 'img', '2.png'));

MINU1 = LoadMntVF12(fullfile(sample_dir, 'vf12', 'mnt', '1.mnt'));
MINU2 = LoadMntVF12(fullfile(sample_dir, 'vf12', 'mnt', '2.mnt'));
MINU = [MINU1; MINU2];

mask1 = imread(fullfile(sample_dir, 'mask', 'm1.png')) / 255;
mask2 = imread(fullfile(sample_dir, 'mask', 'm2.png')) / 255;

img = zeros(size(img1));
ori = 91 * ones(size(ori1));
mask = mask1 + 2 * mask2;

img = merge_arr(img, img1, img2, mask);
ori = merge_arr(ori, ori1, ori2, mask);
mask = double(mask > 0);

param.method_shape = 'Given';
param.method_of = 'Given';
param.h = max(MINU(:, 2));
param.w = max(MINU(:, 1));
param.DIR = ori;
param.mask = mask;

I = ReconstructFingerprint_Guan(MINU, param); %#ok<NASGU>

function arr = merge_arr(arr, arr1, arr2, mask)
arr(mask == 1) = arr1(mask == 1);
arr(mask == 2) = arr2(mask == 2);
arr(mask == 3) = (arr1(mask == 3) + arr2(mask == 3)) / 2;
end

function [ori, mask, img] = extract_feature(fpath)
img = imread(fpath);
blk_size = 16;
smooth_size = 16;
[ori, ~, roi] = ComputeDir(img, blk_size, smooth_size);
ori = imresize(ori, size(img), 'nearest');
mask = double(roi);
ori(mask == 0) = 91;
end
