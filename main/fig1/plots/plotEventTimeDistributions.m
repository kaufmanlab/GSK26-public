function plotEventTimeDistributions(eventInfo, eventName, yLim, zeroLabel)
% Plot the distribution of the desired event as a box plot

% Make figure
fig;
hold on;
axis off
ax = gca;

% Box plotting parameters
lw = 0.5;
bxw = 0.25;
alpha = 1;
spacing = [1,1.75];
buff = 2.5;
axlocs = [spacing; spacing + buff; spacing + buff*2; spacing + buff*3; spacing + buff*4];
count = 1;
% Plot boxes
for dataset = eventInfo
    % Plot
    plotBox(ax, dataset.([eventName '_L']), axlocs(count,1), [0, 0, 1], alpha, bxw, lw, [], 1)
    plotBox(ax, dataset.([eventName '_R']), axlocs(count,2), [1, 0, 0], alpha, bxw, lw, [], 1)

    count = count + 1;
    
end
ylim(yLim)
xlim([min(axlocs(:)) - 1, max(axlocs(:)) + 1])

% Add vertical axis information
ticks = [0 yLim(2)];
tickLabels = arrayfun(@(x) cellstr(num2str(x)), ticks);
tickLabels{1} = zeroLabel;
vaxParams.axisOrientation = 'v';
vaxParams.tickLocations = ticks;
vaxParams.tickLabels = tickLabels;
vaxParams.tickLabelLocations = ticks;
vaxParams.axisOffset = 0.5;%-0.02;
vaxParams.fontSize = 8;
vaxParams.lineThickness = 0.5;
AxisMMC(vaxParams.tickLocations(1), vaxParams.tickLocations(end), vaxParams);

% Add horizontal axis information
ticks = mean(axlocs,2);
for t = 1:length(ticks)
    clear haxParams
    haxParams.axisOrientation = 'h';
    haxParams.tickLocations = [axlocs(t,1) - 0.25, axlocs(t,end) + 0.25];
    haxParams.tickLabels = {num2str(t)};
    haxParams.tickLabelLocations = ticks(t);
    haxParams.axisOffset = -50;%-0.02;
    haxParams.axisLabelOffset = -100;%-0.02;
    haxParams.fontSize = 8;
    haxParams.invert = 1;
    haxParams.lineThickness = 0.5;
    AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);
end

end