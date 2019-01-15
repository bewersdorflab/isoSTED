function [] = save_png(path, res)

if ~exist('res', 'var') || isempty(res)
    res = '-r0';
end

h = gcf();
set(h, 'Units', 'Inches');
pos = get(h, 'Position');
set(h, ...
    'PaperPositionMode', 'Auto', ...
    'PaperUnits', 'Inches', ...
    'PaperSize', [pos(3), pos(4)]);
print(h, path, '-dpng', res);
end







