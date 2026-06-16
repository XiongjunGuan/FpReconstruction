clear; close all;

script_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(fileparts(script_dir));

img = imread(fullfile(repo_root, 'examples', 'data', '2', 'img', '0.png'));
figure; imshow(img);

mask = zeros(size(img));
mask(342:402, 416:544) = 1;
f1 = img;
f1(mask == 0) = 255;
imwrite(f1, fullfile(repo_root, 'examples', 'data', '2', 'img', '1.png'));
imwrite(mask, fullfile(repo_root, 'examples', 'data', '2', 'mask', 'm1.png'));

mask = zeros(size(img));
mask(392:452, 446:574) = 1;
f2 = img;
f2(mask == 0) = 255;
imwrite(f2, fullfile(repo_root, 'examples', 'data', '2', 'img', '2.png'));
imwrite(mask, fullfile(repo_root, 'examples', 'data', '2', 'mask', 'm2.png'));

mask = zeros(size(img));
mask(432:492, 396:524) = 1;
f3 = img;
f3(mask == 0) = 255;
imwrite(f3, fullfile(repo_root, 'examples', 'data', '2', 'img', '3.png'));
imwrite(mask, fullfile(repo_root, 'examples', 'data', '2', 'mask', 'm3.png'));

mask = zeros(size(img));
mask(492:552, 426:554) = 1;
f4 = img;
f4(mask == 0) = 255;
imwrite(f4, fullfile(repo_root, 'examples', 'data', '2', 'img', '4.png'));
imwrite(mask, fullfile(repo_root, 'examples', 'data', '2', 'mask', 'm4.png'));
