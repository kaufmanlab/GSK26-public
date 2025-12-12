function plotVEAll(outputs, field, inverty)

% Colormap
proxcol = [215, 15, 175]/255;
distcol = [255, 160, 25]/255;

% Figure
fig;
hold on;
hA = gca;
axis off

% Params
lw = 0.5;
bxw = 0.25;
alpha = 1;
spacing = [1,1.75];
buff = 2.5;
axlocs = [spacing; spacing + buff; spacing + buff*2; spacing + buff*3; spacing + buff*4];

jointsP = 1:7;
jointsD = 8:24;
count = 1;
for output = outputs
    xloc = axlocs(count,1);
    % Plot each joint's median as a scatter
    for j = jointsP
        veP = median(output.(field).VEs(:,j));
        scatter(xloc, veP, 'SizeData', 100, 'CData', proxcol, 'Marker', '.');
    end
    % Then plot median as a line
    mveP = median(median(output.(field).VEs(:,jointsP)));
    line([xloc-bxw, xloc+bxw], [mveP, mveP], 'Color', [0,0,0], 'LineWidth', 1)
    
    veD = output.(field).VEs(:,jointsD);
    
    xloc = axlocs(count,2);
    % Plot each joint's median as a scatter
    for j = jointsD
        veD = median(output.(field).VEs(:,j));
        scatter(xloc, veD, 'SizeData', 100, 'CData', distcol, 'Marker', '.');
    end
    % Then plot median as a line
    mveD = median(median(output.(field).VEs(:,jointsD)));
    line([xloc-bxw, xloc+bxw], [mveD, mveD], 'Color', [0,0,0], 'LineWidth', 1)
    
    count = count + 1;
end

ylim([-0.2, 1.1])
xlim([-1, max(axlocs(:)) + 1])

% Horizontal axis
ticks = mean(axlocs,2);
for t = 1:length(ticks)
    haxParams.axisOrientation = 'h';
    haxParams.tickLocations = [axlocs(t,1) - 0.25, axlocs(t,end) + 0.25];
    haxParams.tickLabels = {num2str(t)};
    haxParams.tickLabelLocations = ticks(t);
    haxParams.axisOffset = -0.1;%-0.02;
    haxParams.axisLabelOffset = 100;%-0.02;
    haxParams.fontSize = 7;
    haxParams.invert = 1;
    haxParams.lineThickness = 0.5;
    AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);
end

if inverty
    axoffset = max([axlocs(:)]) + 1.1;
    invert = 1;
    
    ylim([-0.2, 1])
    xlim([0 max([axlocs(:)]) + 2]);
else
    axoffset = -0.1;
    invert = 0;
    
    ylim([-0.2, 1])
    xlim([-1 max(axlocs(:)) + 1]);
end

% Vertical axis
vaxParams.axisOrientation = 'v';
vaxParams.tickLocations = linspace(0,1,5);
vaxParams.tickLabels = arrayfun(@(x) cellstr(num2str(x)), linspace(0,1,5));
vaxParams.tickLabelLocations = linspace(0,1,5);
vaxParams.axisOffset = axoffset;
vaxParams.fontSize = 7;
vaxParams.invert = invert;
vaxParams.axisLabel = 'variance explained';
vaxParams.lineThickness = 0.5;
AxisMMC(vaxParams.tickLocations(1), vaxParams.tickLocations(end), vaxParams);

lineVals = linspace(0, 1, 5);
for t = 1:length(lineVals)
    hL = line(hA, [min(axlocs(:)) - 0.25, max(axlocs(:)) + 0.25], [lineVals(t), lineVals(t)], 'Color', [0,0,0,0.5], 'LineStyle', '--');
    uistack(hL, 'bottom');
end

end