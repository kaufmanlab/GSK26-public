function plotTargetClassifierPerformanceAll(outputs)
% Plot classifier performance for each subject
% on a single axis with horizontal tiling controlled by xOffset.

xOffset = 100; % default spacing between panels (in ms)

% Figure
fig;
hold on
axis off

colors = [[79,178,61]; [199,72,149]; [128,128,128]]/255;

% Compute grandmean
perfsM1 = [];
perfsS1 = [];
for output = outputs
    perfsM1 = cat(1, perfsM1, output.M1.perfBins);
    perfsS1 = cat(1, perfsS1, output.S1.perfBins);
end
tPts = output.M1(1).tPts';
xStart = tPts(1);
zeroBin = find(tPts == 0);

% Plot grand mean
% Chance line
line([tPts(1) tPts(end)], [50 50], 'Color', [0.5 0.5 0.5], ...
    'LineWidth', 1, 'LineStyle', '--');

% M1 mean ± SEM
meanperfs = mean(perfsM1)'; 
semperfs = std(perfsM1)' ./ sqrt(size(perfsM1,1));
fill([tPts; flipud(tPts)], ...
     [meanperfs - semperfs; flipud(meanperfs + semperfs)], ...
     colors(2,:), 'EdgeColor', colors(2,:), 'FaceAlpha', 0.5);
plot(tPts, meanperfs, 'Color', colors(2,:), 'LineWidth', 2);

% S1 mean ± SEM
meanperfs = mean(perfsS1)'; 
semperfs = std(perfsS1)' ./ sqrt(size(perfsS1,1));
fill([tPts; flipud(tPts)], ...
     [meanperfs - semperfs; flipud(meanperfs + semperfs)], ...
     colors(1,:), 'EdgeColor', colors(1,:), 'FaceAlpha', 0.5);
plot(tPts, meanperfs, 'Color', colors(1,:), 'LineWidth', 2);

% Axes
axis off;

% Vertical axis
vaxParams.axisOrientation = 'v';
vaxParams.tickLocations = [30 50 100];
vaxParams.tickLabels = {'30', '50', '100'};
vaxParams.tickLabelLocations = [30 50 100];
vaxParams.axisOffset = -110;
vaxParams.fontSize = 7;
vaxParams.axisLabel = 'performance';
vaxParams.lineThickness = 0.5;
AxisMMC(vaxParams.tickLocations(1), vaxParams.tickLocations(end), vaxParams);

% Horizontal axis
haxParams.axisOrientation = 'h';
haxParams.tickLocations = [tPts(1) 0 tPts(end)];
haxParams.tickLabels = cellstr(num2str([tPts(1) 0 tPts(end)]'));
haxParams.tickLabelLocations = [tPts(1) 0 tPts(end)];
haxParams.axisOffset = 35;
haxParams.fontSize = 7;
haxParams.axisLabel = 'time from cue onset (ms)';
haxParams.lineThickness = 0.5;
AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);

% Plot each mouse
nMice = numel(outputs);
for i = 1:nMice
    tPtsI = tPts + i*range(tPts) + i*xOffset; % horizontal offset for each subject
    
    output = outputs(i);
    
    % Chance line
    line([tPtsI(1) tPtsI(end)], [50 50], 'Color', [0.5 0.5 0.5], ...
        'LineWidth', 1, 'LineStyle', '--');
    
    % M1
    perfs = cat(1, output.M1.perfBins);
    meanperfs = mean(perfs)'; 
    semperfs = std(perfs)' ./ sqrt(size(perfs,1));
    fill([tPtsI; flipud(tPtsI)], ...
         [meanperfs - semperfs; flipud(meanperfs + semperfs)], ...
         colors(2,:), 'EdgeColor', colors(2,:), 'FaceAlpha', 0.5);
    plot(tPtsI, meanperfs, 'Color', colors(2,:), 'LineWidth', 2);
    
    % S1
    perfs = cat(1, output.S1.perfBins);
    meanperfs = mean(perfs)'; 
    semperfs = std(perfs)' ./ sqrt(size(perfs,1));
    fill([tPtsI; flipud(tPtsI)], ...
         [meanperfs - semperfs; flipud(meanperfs + semperfs)], ...
         colors(1,:), 'EdgeColor', colors(1,:), 'FaceAlpha', 0.5);
    plot(tPtsI, meanperfs, 'Color', colors(1,:), 'LineWidth', 2);
    
    % Axis tweaks
    axis off
    haxParams.tickLocations = [tPtsI(1) tPtsI(zeroBin) tPtsI(end)];
    haxParams.tickLabels = cellstr(num2str([tPts(1) 0 tPts(end)]'));
    haxParams.tickLabelLocations = [tPtsI(1) tPtsI(zeroBin) tPtsI(end)];
    AxisMMC(haxParams.tickLocations(1), haxParams.tickLocations(end), haxParams);
end

% Set combined limits
xEnd = tPtsI(end);
xlim([xStart - 10 xEnd]);
ylim([30 100])

axis off;
end
