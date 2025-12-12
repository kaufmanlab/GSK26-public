function plotJointKinematicsCVPCA(lossTests)
% Pair plot of cvPCA results

% Figure
fig;
axis off
hold on;

% Params
colors = turbo(size(lossTests,1));
markers = {'s', 'x', '+', '*', 'o'};

% Loop over mice
for mouseN = 1:size(lossTests,1)
    
    % Angles
    mouseLoss = lossTests(mouseN,:,1);
    [mouseBestA, mouseBestDimA] = min(mouseLoss);
    
    % Velocities
    mouseLoss = lossTests(mouseN,:,2);
    [mouseBestV, mouseBestDimV] = min(mouseLoss);
    
    plot([1,2], [mouseBestDimA, mouseBestDimV], 'Marker', markers{mouseN}, 'MarkerFaceColor', colors(mouseN,:), 'Color', colors(mouseN,:), 'MarkerSize', 5, 'DisplayName', sprintf('mouse %i', mouseN))
end

% Horizontal axis for angles
haxParams.axisOrientation = 'h';
haxParams.tickLocations = [1];
haxParams.tickLabels = {'angles'};
haxParams.tickLabelLocations = [1];
haxParams.axisOffset = 1;%-0.02;
haxParams.axisLabelOffset = 0;%-0.02;
haxParams.fontSize = 8;
haxParams.invert = 0;
haxParams.axisLabel = '';
haxParams.tickLength = 0.2;
haxParams.lineThickness = 0.5;
AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);

% Horizontal axis for angles
haxParams.axisOrientation = 'h';
haxParams.tickLocations = [2];
haxParams.tickLabels = {'velocities'};
haxParams.tickLabelLocations = [2];
haxParams.axisOffset = 1;%-0.02;
haxParams.axisLabelOffset = 0;%-0.02;
haxParams.fontSize = 8;
haxParams.invert = 0;
haxParams.axisLabel = '';
haxParams.tickLength = 0.2;
haxParams.lineThickness = 0.5;
AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);

% Vertical axis
vaxParams.axisOrientation = 'v';
vaxParams.tickLocations = 2:2:16;
vaxParams.tickLabels = {'2', '4', '6', '8', '10', '12', '14', '16'};
vaxParams.tickLabelLocations = 2:2:16;
vaxParams.axisOffset = 0.5;%-0.02;
vaxParams.axisLabelOffset = 0.3;%-0.02;
vaxParams.fontSize = 8;
vaxParams.invert = 0;
vaxParams.axisLabel = 'dimensionality';
vaxParams.tickLength = 0.03;
vaxParams.lineThickness = 0.5;
AxisMMC(vaxParams.tickLocations(1), vaxParams.tickLocations(end), vaxParams);

ylim([0 16])
xlim([0.25 2.5])

end