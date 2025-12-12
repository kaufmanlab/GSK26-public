function plotVE(output, inverty)
% Plot the variance explained as violins and scatter plots

% Params
prox_cmap = repmat([215, 15, 175]/255, 7,1);
dist_cmap = repmat([255, 160, 25]/255, 17,1);
cmap = [prox_cmap; dist_cmap];
axvals = {[1,2,3],  [5],  [7,8,9],  [12,13,14,15], [17,18,19,20],  [22,23],  [25,26,27],  [29,30,31,32]};
output.outcomeAxVals = [axvals{:}];
output.outcomeNames = {'', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '', '',  '', '', '', ''};
behavField = 'jointAngles';

% Figure
fig;
hold on;
hA = gca;
axis off

% Find indices with field matching "variable" input
inds = cellfun(@(x)contains(x, sprintf('lag%i%s', 1, behavField)), output.outcomeIndices);

% Params
ax = 'y';
alpha = 0.35;
linesmin = 0;
linesmax = 1;
nlines = 5;
dotSz = 20;
bxw = 0.33;
lw = 0.5;

% Make violins
violins(hA, output.VEs(:,inds), output.outcomeNames, cmap, output.outcomeAxVals, ax, alpha, dotSz, linesmin, linesmax, nlines)

% Add variable names below x ticks
varnames = {{'f', 'a', 'r'}, {'f'}, {'f', 'd', 'r'}, {'1', '2', '3', '4'}, {'1', '2', '3', '4'}, {'1', '4'}, {'1-2', '2-3', '3-4'},  {'1', '2', '3', '4'}};
groupnames = {'shoulder', 'elbow', 'wrist', 'MCPf', 'MCPa', 'MCPo', 'PIPs', 'PIPf'};
for i = 1:length(axvals)
    
    clear haxParams
    haxParams.axisOrientation = 'h';
    haxParams.tickLocations = axvals{i};
    haxParams.tickLabels = varnames{i};
    haxParams.tickLabelLocations = axvals{i};
    haxParams.axisOffset = -0.075;
    haxParams.fontSize = 7;
    haxParams.lineThickness = 0.5;
    AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);
    text(mean(axvals{i}), -0.2, groupnames{i}, 'HorizontalAlignment', 'center', 'FontSize', 12)
end

if inverty
    axoffset = max([axvals{:}]) + 1.1;
    invert = 1;
    
    ylim([-0.2, 1])
    xlim([0 max([axvals{:}]) + 2]);
else
    axoffset = -0.1;
    invert = 0;
    
    ylim([-0.2, 1])
    xlim([-1 max(output.outcomeAxVals) + 1]);
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

end