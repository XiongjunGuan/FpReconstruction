clear; close all;

demo_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(fileparts(demo_dir));
run(fullfile(repo_root, 'matlab', 'startup.m'));

sample_dir = fullfile(repo_root, 'examples', 'data', '2');
img_dir = fullfile(sample_dir, 'img');
mask_dir = fullfile(sample_dir, 'mask');
mnt_dir = fullfile(sample_dir, 'vf12', 'mnt');

flst = ["1", "2", "3", "4"];

for i = 1:length(flst)
    [ori_i, mask_i, img_i] = extract_feature(fullfile(img_dir, flst(i) + ".png"));
    mask_i = double(imread(fullfile(mask_dir, "m" + flst(i) + ".png")));
    ori_i = double(ori_i);
    img_i = double(img_i);
    MINU_i = LoadMntVF12(fullfile(mnt_dir, flst(i) + ".mnt"));

    if i == 1
        ori = ori_i;
        mask = mask_i;
        img = img_i;
        weight = double(mask_i > 0);
        MINU = MINU_i;
    else
        overlap = (mask .* mask_i) > 0;
        nonoverlap = (mask_i > 0) .* (mask == 0);

        ori(overlap > 0) = ori(overlap > 0) + ori_i(overlap > 0);
        img(overlap > 0) = img(overlap > 0) + img_i(overlap > 0);
        weight(overlap > 0) = weight(overlap > 0) + 1;

        ori(nonoverlap > 0) = ori_i(nonoverlap > 0);
        img(nonoverlap > 0) = img_i(nonoverlap > 0);
        weight(nonoverlap > 0) = 1;

        mask = mask + mask_i;
        MINU = [MINU; MINU_i];
    end
end

weight(weight == 0) = 1;
ori = ori ./ weight;
img = img ./ weight;
mask = double(mask > 0);

param.method_shape = 'Given';
param.method_of = 'Given';
param.h = max(MINU(:, 2));
param.w = max(MINU(:, 1));
param.DIR = ori;
param.mask = mask;

I = ReconstructFingerprint_Guan(MINU, param); %#ok<NASGU>

function [ori, mask, img] = extract_feature(fpath)
img = imread(fpath);
blk_size = 16;
smooth_size = 16;
[ori, ~, roi] = ComputeDir(img, blk_size, smooth_size);
ori = imresize(ori, size(img), 'nearest');
mask = double(roi);
ori(mask == 0) = 91;
end
