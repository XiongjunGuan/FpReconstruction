clear; close all;

script_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(fileparts(script_dir));

img = imread(fullfile(repo_root, 'examples', 'datas', '83.bmp'));
img = rgb2gray(img);

blk_size = 16;
smooth_size = 16;
[ori, ~, ~] = ComputeDir(img, blk_size, smooth_size);
mask = imread(fullfile(repo_root, 'examples', 'datas', 'm83.bmp'));
mask = rgb2gray(mask);
mask = imresize(mask, size(ori));
mask = mask > 100;

figure(1), imshow(img * 0 + 255), DrawDir(1, ori, 16, 'g2', mask);
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf, fullfile(repo_root, 'examples', 'datas', 'res', '1.png'), '-dpng', '-r300');

img = imread(fullfile(repo_root, 'examples', 'datas', 'b83roll.bmp'));
[ori, ~, ~] = ComputeDir(img, blk_size, smooth_size);
mask = imread(fullfile(repo_root, 'examples', 'datas', 'm83roll.jpg'));
mask = imresize(mask, size(ori));
mask = mask > 100;

figure(2), imshow(img * 0 + 255), DrawDir(2, ori, 16, 'r2', mask);
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf, fullfile(repo_root, 'examples', 'datas', 'res', '2.png'), '-dpng', '-r300');

[opatch, mpatch] = get_patch(ori, 402, 373, 2);
figure(3), imshow(imresize(mpatch, 16) * 0 + 255), DrawDir(3, opatch, 16, 'r2', mpatch);
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf, fullfile(repo_root, 'examples', 'datas', 'res', '3.png'), '-dpng', '-r300');

[opatch, mpatch] = get_patch(ori, 498, 453, 2);
figure(4), imshow(imresize(mpatch, 16) * 0 + 255), DrawDir(4, opatch, 16, 'r2', mpatch);
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf, fullfile(repo_root, 'examples', 'datas', 'res', '4.png'), '-dpng', '-r300');

[opatch, mpatch] = get_patch(ori, 339, 284, 2);
figure(5), imshow(imresize(mpatch, 16) * 0 + 255), DrawDir(5, opatch, 16, 'r2', mpatch);
set(gca, 'LooseInset', get(gca, 'TightInset'));
print(gcf, fullfile(repo_root, 'examples', 'datas', 'res', '5.png'), '-dpng', '-r300');

function [res_arr, res_mask] = get_patch(arr, c, r, hl)
r = round(r * 50 / 800);
c = round(c * 50 / 800);
res_arr = arr(r - hl:r + hl, c - hl:c + hl);
res_mask = ones(size(res_arr));
end
