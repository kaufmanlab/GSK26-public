function violin(hA, Y, axLoc, color, alpha, mrkSz, mxStr, txtCol, fntSz, bw)

if isempty(hA)
    hA = gca;
end

%% Calculate the kernel density

if axLoc(1) == 0
    plotY = 1;
    axLoc = axLoc(2);
else
    plotY = 0;
    axLoc = axLoc(1);
end

if nargin > 9
    [f, u, ~] = ksdensity(Y, 'Bandwidth', bw);
else
    [f, u, ~] = ksdensity(Y);
end

f = f/max(f) * 0.3; %normalize
med = nanmedian(Y);
avg = nanmean(Y);
f = f';
u = u';

%% Plot the violins

hold(hA, 'on');

if ~plotY % Violin is plotted with distribution spanning Y axis direction
    
    hV = fill(hA, [f + axLoc; flipud(axLoc - f)], [u; flipud(u)], color, 'FaceAlpha', alpha, 'EdgeColor', color, 'LineWidth', 0.25);
    
    if ~isempty(mrkSz)
        hVals = scatter(hA, axLoc + 0.075 * randn(1, length(Y)), Y, 'b.', 'SizeData', mrkSz, 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'MarkerFaceAlpha', alpha);
    end
    
    hMed = plot(hA, [interp1(u, f + 1, med) + axLoc - 1, interp1(flipud(u), flipud(1 - f), med) + axLoc - 1], [med med], 'Color', [0,0,0], 'LineWidth', 2);
    
%     hMean = plot(hA, [interp1(u, f + 1, med) + axLoc - 1, interp1(flipud(u), flipud(1 - f), med) + axLoc - 1], [med med], 'b-', 'LineWidth', 1);
        
    if nargin > 6
        hMxStr = text(hA, axLoc, max(u) * 1.1, mxStr, 'Color', txtCol, 'FontSize', fntSz, 'HorizontalAlignment', 'center');
    end
    
    
else
    
    hV = fill(hA, [u; flipud(u)], [f + axLoc; flipud(axLoc - f)] , color, 'FaceAlpha', alpha, 'EdgeColor', color, 'LineWidth', 0.25);
    
    if ~isempty(mrkSz)
        hVals = scatter(hA, Y, axLoc + 0.075 * randn(1, length(Y)), 'b.', 'SizeData', mrkSz, 'MarkerFaceColor', color, 'MarkerEdgeColor', color, 'MarkerFaceAlpha', alpha);
    end
    
    hMed = plot(hA, [med med], [interp1(u, f + 1, med) + axLoc - 1, interp1(flipud(u), flipud(1 - f), med) + axLoc - 1], 'Color', [0,0,0], 'LineWidth', 0.5);
    
%     hMean = plot(hA, [med med], [interp1(u, f + 1, med) + axLoc - 1, interp1(flipud(u), flipud(1 - f), med) + axLoc - 1], 'b-', 'LineWidth', 1);
    
    if nargin > 6
        hMxStr = text(hA, max(u) * 1.1, axLoc, mxStr, 'Color', txtCol, 'FontSize', fntSz, 'HorizontalAlignment', 'center');
    end
    
end


end