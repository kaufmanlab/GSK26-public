function plotNContactsDistributions(eventInfo)
% Plot bar plots for the number of contacts within 1s of the cue
fig;
hold on;
axis off

% Get counts
[countsR, ~] = histcounts([eventInfo.nGrasps_R], 'BinMethod', 'integers', 'Normalization', 'probability');
[countsL, ~] = histcounts([eventInfo.nGrasps_L], 'BinMethod', 'integers', 'Normalization', 'probability');
xvals = 0:max([eventInfo.nGrasps_R]);

% Plot bar plot
b = bar(xvals, [[countsL 0 0];countsR], 'FaceColor', 'flat');
b(1).BarWidth = 1;
b(1:2:end).CData = [0,0,1];
b(2:2:end).CData = [1,0,0];
b(1).BaseLine.Color = 'white';
yticks = get(gca, 'YTick');

% Add vertical axis information
tickLabels = arrayfun(@(x) cellstr(num2str(x)), yticks);
vaxParams.axisOrientation = 'v';
vaxParams.tickLocations = yticks;
vaxParams.tickLabels = tickLabels;
vaxParams.tickLabelLocations = yticks;
vaxParams.axisOffset = -0.5;
vaxParams.fontSize = 8;
vaxParams.lineThickness = 0.5;
vaxParams.axisLabel = 'probability';
AxisMMC(vaxParams.tickLocations(1), vaxParams.tickLocations(end), vaxParams);

% Add horizontal axis information
tickLabels = arrayfun(@(x) cellstr(num2str(x)), xvals);
haxParams.axisOrientation = 'h';
haxParams.tickLocations = xvals;
haxParams.tickLabels = tickLabels;
haxParams.tickLabelLocations = xvals;
haxParams.axisOffset = 0;
haxParams.fontSize = 8;
haxParams.lineThickness = 0.5;
haxParams.axisLabel = 'number of contacts within 1s';
AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);
end