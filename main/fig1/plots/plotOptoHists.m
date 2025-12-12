function plotOptoHists(data)
% Plots histograms of contact times during optogenetic stimulation
% Requires data already concatenated across behavior files into a "data"
% struct

% Separate trials
trialsNormal = [data.success] == 1 & [data.optoProblem] == 0 & [data.optoTrial] == 0 & [data.grabTimeC] > [data.liftTimeC] & [data.wrongGrabFirst] == 0;
trialsOpto = [data.success] == 1 & [data.optoProblem] == 0 & [data.optoTrial] == 1 & [data.grabTimeC] > [data.liftTimeC] & [data.wrongGrabFirst] == 0;

% Get data
normalContactTimes = [data(trialsNormal).grabTimeC]/1000;
optoContactTimes = [data(trialsOpto).grabTimeC]/1000;

fig;
hold on;
axis off;

% Get counts
nBins = 30;
xMin = 0;
xMax = 9;
binEdges = linspace(xMin, xMax, nBins);
[vals_N,~] = histcounts(normalContactTimes, 'BinEdges', binEdges, 'Normalization', 'probability');
[vals_O,~] = histcounts(optoContactTimes, 'BinEdges', binEdges, 'Normalization', 'probability');
yMax = round(max([vals_N, vals_O]),1) + 0.1;

% Plot histogram
histogram(normalContactTimes, 'BinEdges', binEdges, 'Normalization', 'probability', 'DisplayStyle', 'stairs', 'LineWidth', 1, 'EdgeColor', [0,0,0]);
histogram(optoContactTimes, 'BinEdges', binEdges, 'Normalization', 'probability', 'DisplayStyle', 'stairs', 'LineWidth', 1, 'EdgeColor', [0,0.9,0.9]);

% Add title
xlim([-1 xMax]);
text(6, 0.3*yMax, sprintf('%i inactivation trials', sum(trialsOpto)));
text(6, 0.4*yMax, '2 mice');

% Add vertical axis information
vaxParams.axisOrientation = 'v';
vaxParams.tickLocations = [0, yMax];
vaxParams.tickLabelLocations = [0, yMax];
vaxParams.axisOffset = -0.25;
vaxParams.axisLabel = 'probability';
vaxParams.fontSize = 11;
AxisMMC(vaxParams.tickLocations(1), vaxParams.tickLocations(end), vaxParams);

% Add horizontal axis information
haxParams.axisOrientation = 'h';
haxParams.tickLocations = [0, 3, 6, 9];
haxParams.tickLabels = {'cue', '3', '6', '9'};
haxParams.tickLabelLocations = [0, 3, 6, 9];
haxParams.axisOffset = 0;
haxParams.fontSize = 11;
AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);

% Add bar at top
fill([0, 3, 3, 0], [-0.04 -0.04 -0.05 -0.05], [0,0.9,0.9], 'FaceColor', [0,0.9,0.9], 'EdgeColor', [0,0.9,0.9]);

end