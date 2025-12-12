function plotJointKinematicsCVPCALoss(lossTests, lossSEMs, mouseN, maxDims)
% Loss curve plot of cvPCA results

% Figure
fig;
axis off
hold on

% Params
colors = [[0, 0, 0]; [0.5,0.5,0.5]];

% Only one mouse is plotted
% Angles
mouseLoss = lossTests(mouseN,2:end,1);
mouseSEMs = lossSEMs(mouseN,2:end,1);
plot(2:maxDims, mouseLoss, '-', 'Color', colors(1,:), 'LineWidth', 1);
for d = 1:length(lossSEMs)-1
    plot(1 + [d d], mouseLoss(d) + [-1 1] * mouseSEMs(d), '-', 'Color', colors(1,:), 'LineWidth', 1);
end
[mouseBest, mouseBestX] = min(mouseLoss);
plot(mouseBestX+1, mouseBest, 'k.', 'MarkerSize', 15, 'Color', colors(1,:));

% Velocities
mouseLoss = lossTests(mouseN,2:end,2);
mouseSEMs = lossSEMs(mouseN,2:end,2);
% colors = colormapHSV(colors, [], [], 0.65);
plot(2:maxDims, mouseLoss, '-', 'Color', colors(2,:), 'LineWidth', 1);
for d = 1:length(lossSEMs)-1
    plot(1 + [d d], mouseLoss(d) + [-1 1] * mouseSEMs(d), '-', 'Color', colors(2,:), 'LineWidth', 1);
end
[mouseBest, mouseBestX] = min(mouseLoss);
plot(mouseBestX+1, mouseBest, 'k.', 'MarkerSize', 15, 'Color', colors(2,:));

ylim([0,1])

% Vertical axis
vaxParams.axisOrientation = 'v';
vaxParams.tickLocations = 0.2:0.2:1.2;
vaxParams.tickLabels = {'0.2', '0.4', '0.6', '0.8', '1', '1.2'};
vaxParams.tickLabelLocations = 0.2:0.2:1.2;
vaxParams.axisOffset = 1;%-0.02;
vaxParams.axisLabelOffset = 1.15;%-0.02;
vaxParams.fontSize = 8;
vaxParams.invert = 0;
vaxParams.axisLabel = 'test loss';
vaxParams.tickLength = 0.2;
vaxParams.lineThickness = 0.5;
AxisMMC(vaxParams.tickLocations(1), vaxParams.tickLocations(end), vaxParams);

% Horizontal axis
haxParams.axisOrientation = 'h';
haxParams.tickLocations = 2:2:16;
haxParams.tickLabels = {'2', '4', '6', '8', '10', '12', '14', '16'};
haxParams.tickLabelLocations = 2:2:16;
haxParams.axisOffset = 0.2;%-0.02;
haxParams.axisLabelOffset = 0.1;%-0.02;
haxParams.fontSize = 8;
haxParams.invert = 0;
haxParams.axisLabel = 'dimensionality';
haxParams.lineThickness = 0.5;
AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);

end