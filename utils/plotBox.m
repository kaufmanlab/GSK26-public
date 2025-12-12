function plotbox(ax, data, axloc, color, alpha, bxw, lw, msize, plotY)
% Makes a boxplot
hold(ax, 'on');

% Get values
md = median(data);
qtls = quantile(data, [0.25 0.75]);
iqrange = iqr(data);
outmx = qtls(2) + 1.5*iqrange;
outmn = qtls(1) - 1.5*iqrange;
outinds = data > outmx | data < outmn;
outs = data(outinds);
mx = max(data(~outinds));
mn = min(data(~outinds));

outmsz = 10;

if plotY
    % Distribution spans Y axis, box located at x coordinate
    
    % Make line to max
    line([axloc, axloc], [qtls(2), mx], 'LineStyle', '-', 'Color', [0,0,0], 'LineWidth', lw, 'Parent', ax)
    % Make line to min
    line([axloc, axloc], [mn, qtls(1)], 'LineStyle', '-', 'Color', [0,0,0], 'LineWidth', lw, 'Parent', ax)
    % Make box
    fill([axloc - bxw, axloc + bxw, axloc + bxw, axloc - bxw], [qtls(1), qtls(1), qtls(2), qtls(2)], color, 'FaceColor',  color, 'EdgeColor', [0,0,0], 'FaceAlpha', alpha, 'LineWidth', lw, 'Parent', ax)
    % Make median line and dot
    line([axloc - bxw, axloc + bxw], [md, md], 'LineStyle', '-', 'Color', [0,0,0], 'LineWidth', lw, 'Parent', ax)
    plot([axloc, axloc], [md, md], 'Marker', '.', 'Color', [0,0,0], 'MarkerSize', lw*10, 'Parent', ax)
    % Plot outliers
    if ~isempty(outs)
        scatter(ax, axloc * ones(1,length(outs)), outs, '.', 'SizeData', outmsz, 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'MarkerFaceAlpha', alpha);
    end
    % Add data points
    if ~isempty(msize)
        scatter(ax, axloc + 0.075 * randn(1, length(data)), data, '.', 'SizeData', msize, 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'MarkerFaceAlpha', alpha);
    end
    
else
    
    % Distribution spans Y axis, box located at x coordinate
    
    % Make line to max
    line([qtls(2), mx], [axloc, axloc], 'LineStyle', '-', 'Color', [0,0,0], 'LineWidth', lw, 'Parent', ax)
    % Make line to min
    line([mn, qtls(1)], [axloc, axloc], 'LineStyle', '-', 'Color', [0,0,0], 'LineWidth', lw, 'Parent', ax)
    % Make box
    fill([qtls(1), qtls(1), qtls(2), qtls(2)], [axloc - bxw, axloc + bxw, axloc + bxw, axloc - bxw], color, 'FaceColor',  color, 'EdgeColor', [0,0,0], 'FaceAlpha', alpha, 'LineWidth', lw, 'Parent', ax)
    % Make median line and dot
    line([md, md], [axloc - bxw, axloc + bxw], 'LineStyle', '-', 'Color', [0,0,0], 'LineWidth', lw, 'Parent', ax)
    plot([md, md], [axloc, axloc], 'Marker', '.', 'Color', [0,0,0], 'MarkerSize', lw*10, 'Parent', ax)
    % Plot outliers
    if ~isempty(outs)
        scatter(ax, outs, axloc * ones(1,length(outs)), '.', 'SizeData', outmsz, 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'MarkerFaceAlpha', alpha);
    end
    % Add data points
    if ~isempty(msize)
        scatter(ax, data, axloc + 0.075 * randn(1, length(data)), '.', 'SizeData', msize, 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'MarkerFaceAlpha', alpha);
    end
    
end

end