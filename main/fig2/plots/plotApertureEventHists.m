function plotApertureEventHists(kinematics)
% Plot the histograms of aperture-related event timings across all mice

% Figure
[~, tl] = fig([2,1]);

% Params
liftCol = [130, 235, 118]/255;
collectCol = [72, 188, 255]/255;
extendCol = [230, 40, 151]/255;
bins = min([kinematics(find([kinematics.nPeaks] == 1)).collectTime]):10:max([kinematics(find([kinematics.nPeaks] == 1)).collectTime]);

% Histograms
% Lefts
nexttile(tl);
hold on;
axis off
trialsL = find([kinematics.LR] == 1 & [kinematics.nPeaks] == 1);
h1 = histogram([kinematics(trialsL).collectTime], bins, 'DisplayStyle', 'stairs', 'EdgeColor', collectCol, 'LineWidth', 1.5, 'Normalization', 'probability');
h2 = histogram([kinematics(trialsL).extendTime], bins, 'DisplayStyle', 'stairs', 'EdgeColor', extendCol, 'LineWidth', 1.5, 'Normalization', 'probability');
line([0, 0], [0, 0.6], 'LineStyle', '--', 'Color', [liftCol 0.5], 'LineWidth', 2)

% Plot horizontal axis 
ticks = [0 50 100 150 200 250];
tickLabels = {'lift', '50', '', '150', '', '250'};
clear haxParams
haxParams.axisOrientation = 'h';
haxParams.tickLocations = ticks;
haxParams.tickLabels = tickLabels;
haxParams.tickLabelLocations = ticks;
haxParams.axisOffset = 0;%-0.02;
haxParams.fontSize = 12;
AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);

% Histograms
% Lefts
nexttile(tl);
hold on;
axis off
trialsL = find([kinematics.LR] == 2 & [kinematics.nPeaks] == 1);
h3 = histogram([kinematics(trialsL).collectTime], 30:10:250, 'DisplayStyle', 'stairs', 'EdgeColor', collectCol, 'LineWidth', 1.5, 'Normalization', 'probability');
h4 = histogram([kinematics(trialsL).extendTime], 30:10:250, 'DisplayStyle', 'stairs', 'EdgeColor', extendCol, 'LineWidth', 1.5, 'Normalization', 'probability');
line([0, 0], [0, 0.6], 'LineStyle', '--', 'Color', [liftCol 0.5], 'LineWidth', 2)

% Plot horizontal axis 
ticks = [0 50 100 150 200 250];
tickLabels = {'lift', '50', '', '150', '', '250'};
clear haxParams
haxParams.axisOrientation = 'h';
haxParams.tickLocations = ticks;
haxParams.tickLabels = tickLabels;
haxParams.tickLabelLocations = ticks;
haxParams.axisOffset = 0;%-0.02;
haxParams.fontSize = 12;
AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);

% Set limits
xLims = [-15, bins(end)];
yLims = [-0.02, max([h1.Values, h2.Values, h3.Values, h4.Values])];
nexttile(tl,1);
xlim(xLims)
ylim(yLims)

% Plot vertical axis 
ticks = [0 yLims(2)];
tickLabels = {'0', num2str(round(yLims(2),2))};
clear vaxParams
vaxParams.axisOrientation = 'v';
vaxParams.tickLocations = ticks;
vaxParams.tickLabels = tickLabels;
vaxParams.tickLabelLocations = ticks;
vaxParams.axisOffset = -10;%-0.02;
vaxParams.fontSize = 12;
vaxParams.axisLabel = 'probability';
AxisMMC(vaxParams.tickLocations(1), vaxParams.tickLocations(end), vaxParams);

nexttile(tl,2);
xlim(xLims)
ylim(yLims)

% Plot vertical axis 
ticks = [0 yLims(2)];
tickLabels = {'0', num2str(round(yLims(2),2))};
clear vaxParams
vaxParams.axisOrientation = 'v';
vaxParams.tickLocations = ticks;
vaxParams.tickLabels = tickLabels;
vaxParams.tickLabelLocations = ticks;
vaxParams.axisOffset = -10;%-0.02;
vaxParams.fontSize = 12;
vaxParams.axisLabel = 'probability';
AxisMMC(vaxParams.tickLocations(1), vaxParams.tickLocations(end), vaxParams);