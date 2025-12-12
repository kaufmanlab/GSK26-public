function plotRTClassifierCorrelationAll(outputs, eventName, method)
% Plot the correlation between the real and the predicted RTs

% Figure
fig;
hold on;
ax = gca;
axis off

% Params
colors = turbo(length(outputs));
markers = {'s', 'x', '+', '*', 'o'};

% Loop over mice
corrsM1 = [];
corrsS1 = [];
mouseN = 1;
for mouse = outputs
    % M1
    crossingsM1 = cell2mat(cellfun(@(x) [x.crosstime], {mouse.M1(:).projections}, 'UniformOutput', false));
    rtM1 = cell2mat(cellfun(@(x) [x.(eventName)], {mouse.M1(:).projections}, 'UniformOutput', false));
    % Compares original values to original + decoded values, as
    % decoded values should be 0 if perfect information
    corrM1 = corrcoef(rtM1(~isnan(crossingsM1)) + crossingsM1(~isnan(crossingsM1)), rtM1(~isnan(crossingsM1)));
    
    % S1
    crossingsS1 = cell2mat(cellfun(@(x) [x.crosstime], {mouse.S1(:).projections}, 'UniformOutput', false));
    rtS1 = cell2mat(cellfun(@(x) [x.(eventName)], {mouse.S1(:).projections}, 'UniformOutput', false));
    corrS1 = corrcoef(rtS1(~isnan(crossingsS1)) + crossingsS1(~isnan(crossingsS1)), rtS1(~isnan(crossingsS1)));
    
    % Connect
    plot([1,3], [corrM1(1,2) corrS1(1,2)], 'Marker', markers{mouseN}, 'MarkerFaceColor', colors(mouseN,:), 'Color', colors(mouseN,:), 'MarkerSize', 5, 'DisplayName', sprintf('mouse %i', mouseN));
    mouseN = mouseN + 1;
    
    corrsM1(end+1) = corrM1(1,2);
    corrsS1(end+1) = corrS1(1,2);
end

p = ranksum(corrsM1, corrsS1)

% Vertical axis
vaxParams.axisOrientation = 'v';
vaxParams.tickLocations = [0 0.25 0.5 0.75 1];
vaxParams.tickLabels = cellstr(num2str([0 0.25 0.5 0.75 1]'));
vaxParams.tickLabelLocations = [0 0.25 0.5 0.75 1];
vaxParams.axisOffset = 0.5;
vaxParams.fontSize = 8;
vaxParams.axisLabel = 'correlation with true RT (r)';
vaxParams.lineThickness = 0.5;
AxisMMC(vaxParams.tickLocations(1), vaxParams.tickLocations(end), vaxParams);

% Horizontal axis
haxParams.axisOrientation = 'h';
haxParams.tickLocations = [1];
haxParams.tickLabels = {'M1'};
haxParams.tickLabelLocations = [1];
haxParams.axisOffset = 0;%-0.02;
haxParams.fontSize = 8;
haxParams.lineThickness = 0.5;
AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);

% Horizontal axis
haxParams.axisOrientation = 'h';
haxParams.tickLocations = [3];
haxParams.tickLabels = {'S1'};
haxParams.tickLabelLocations = [3];
haxParams.axisOffset = 0;%-0.02;
haxParams.fontSize = 8;
haxParams.lineThickness = 0.5;
AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);

setXYLim(ax, 1,1)

end