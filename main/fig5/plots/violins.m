function violins(hA, vals, names, cmap, axvals, ax, alpha, mrkSz, linesmin, linesmax, nlines)

if nargin < 6
    linesmin = 1;
end

if nargin < 7
    linesmax = 1;
end

if nargin < 8
    nlines = 5;
end

% Loop over columns with VE data
for col = 1:size(vals,2)
    if strcmp(ax, 'y')
        axval = [axvals(col), 0];
    else
        axval = [0, axvals(col)];
    end
    violin(hA, vals(:,col), axval, cmap(col,:), alpha, mrkSz, names{col}, cmap(col,:), 18);
end

lineVals = linspace(linesmin, linesmax, nlines);
set(hA, 'YTick', lineVals);
set(hA, 'YTickLabels', lineVals);
for t = 1:length(lineVals)
    if strcmp(ax, 'y')
        hL = line(hA, [min(axvals) - 0.5*min(axvals), max(axvals) + 0.5*min(axvals)], [lineVals(t), lineVals(t)], 'Color', [0,0,0,0.5], 'LineStyle', '--', 'LineWidth', 0.25);
    else
        hL = line(hA, [min(axvals) - 0.5*min(axvals), max(axvals) + 0.5*min(axvals)], [lineVals(t), lineVals(t)], 'Color', [0,0,0,0.5], 'LineStyle', '--', 'LineWidth', 0.25);
    end
    uistack(hL, 'bottom');
end
