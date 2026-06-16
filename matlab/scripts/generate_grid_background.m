figure; clf;
img_size = 100;
imshow(ones(img_size) * 255, []);
hold on;

grid_n = 20;
step = img_size / grid_n;
gray = [0.6 0.6 0.6];

for i = 0:grid_n
    x = i * step + 0.5;
    y = i * step + 0.5;
    line([x x], [1 img_size], 'Color', gray, 'LineWidth', 0.5);
    line([1 img_size], [y y], 'Color', gray, 'LineWidth', 0.5);
end

axis off;
set(gcf, 'PaperPositionMode', 'auto');

script_dir = fileparts(mfilename('fullpath'));
repo_root = fileparts(fileparts(script_dir));
print(gcf, fullfile(repo_root, 'examples', 'datas', 'res', 'grid_10x10.png'), '-dpng', '-r300');
