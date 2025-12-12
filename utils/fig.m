function [hF, tl] = fig(layout, position, color)

% Set tick dir out for all figures, sets for system for consistency
set(groot,'defaultAxesTickDir', 'out');
set(groot,'defaultAxesTickDirMode', 'manual');

% Figure out how to turn "Box" off by default

if nargin < 1
    color = [1,1,1];
    position = [500 500 650 500];
    layout = [];
end

if nargin < 2
    color = [1,1,1];
    position = [500 500 650 500];
end

if nargin < 3
    color = [1,1,1];
end

if ischar(position)
    if strcmp(position, 'full')
        position = [43, 1, 1750, 1010];
    end
end

hF = figure('Color', color, 'Position', position);
if isempty(layout) || ischar(layout)
    tl = tiledlayout('flow', 'TileSpacing', 'compact', 'Padding', 'compact');
    hold on;
else
    tl = tiledlayout(layout(1), layout(2), 'TileSpacing', 'compact', 'Padding', 'compact');
end

end
