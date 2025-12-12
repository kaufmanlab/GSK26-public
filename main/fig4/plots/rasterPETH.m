function rasterPETH(R, M, roi, eventName, preEventMs, postEventMs, clusField, sortField, plotRaster)
% Plots a PETH and an image above of single trial responses, a "raster"

if nargin < 9
    plotRaster = 1;
end

% Parameters
timeBase = 10;
lineWidth = 0.5;
semLineWidth = 0.5;
smoothingMs = 35;

% Decide event x label
if contains(eventName, 'liftTime')
    eventLabel = 'lift';
elseif contains(eventName, 'grab')
    eventLabel = 'contact';
elseif contains(eventName, 'water')
    eventLabel = 'cue';
end

% Successful trials
if isfield(R, 'wrongGrabFirst')
    R = R([R.hasNeuralData] & [R.success] & ~[R.wrongGrabFirst] & [R.goodDLC] == 1 & ~isnan([R.(eventName)]));
else
    R = R([R.hasNeuralData] & [R.success] & ~isnan([R.(eventName)]));
end

% Clusters / Left and right
if ~isfield(R, clusField)
    error('Field .%s is not present in this R struct', clusField);
end
clusters = [R.(clusField)];
% If there are any NaNs, don't include them in the cluster list
uClusters = unique(clusters);
uClusters = uClusters(~isnan(uClusters));

% Create colormaps if none were provided
% For error fills, use lower saturation of the same hue
fillSaturation = 0.2;
if strcmp(clusField, 'LR')
    cmap = [[0 0 1]; [1 0 0]];
else
    cmap = M.cmapClus;
end

% De-saturate the current colormap
cmapLight = rgb2hsv(cmap);
cmapLight(:,2) = fillSaturation * cmapLight(:,2);
cmapLight = hsv2rgb(cmapLight);

% Compute Locked traces
[locked, tRaw] = computeLockedTraces(R, M, roi, 'events', eventName, ...
    preEventMs, postEventMs, timeBase, smoothingMs);

% Figure
fig;
hold on;
axis off

% Set scale
% This allows us to rescale events to (roughly) events/s
scale = 1000 / timeBase;

% Plot locked data and label axis
tOff = 0;
lims = [NaN NaN];
lims = plotPSTHSection(locked, clusters, uClusters, tOff, tRaw, scale, lims, ...
    lineWidth, semLineWidth, 0, 'fills', cmap, cmapLight);

% Axes
% Round limits to reasonable precision (0.1 if max is <5, 1 if >=5)
if lims(2) >= 5
    lims(1) = 0;
    lims(2) = ceil(lims(2));
elseif lims(2) > 0.1
    lims(1) = 0;
    lims(2) = ceil(lims(2) * 10) / 10;
else
    lims(1) = 0;
    lims(2) = 10;
end

% Vertical label
yLabel = 'events/s';

% Vertical axis
clear axParams
axParams.axisOrientation = 'v';
axParams.tickLocations = [lims(1), lims(2)];
axParams.tickLabelLocations = axParams.tickLocations;
axParams.axisOffset = -preEventMs - 50;
axParams.axisLabelOffset = 0.12;
axParams.axisLabel = yLabel;
axParams.fontSize = 8;
axParams.lineThickness = 0.5;
AxisMMC(axParams.tickLocations(1), axParams.tickLocations(end), axParams);

% Plot rasters
if plotRaster
    if isfield(R, sortField)
        sortBy = [R.(sortField)];
    else
        fprintf('%s is not a field of R struct, sorting by max event rate\n', sortField)
        sortBy = [];
    end
    yLims = plotRasterSection(locked, sortBy, clusters, uClusters, cmap, tOff, preEventMs, postEventMs, lims);
else
    yLims = lims;
end
line([0,0], [0, yLims(2)], 'Color', [0,0,0], 'LineWidth', 0.5, 'LineStyle', '--');
text(0, -0.05*lims(2), eventLabel, 'FontName', 'Helvetica Neue', 'FontSize', 6, 'HorizontalAlignment', 'center');
line(-[preEventMs preEventMs] - 25, [0, 0.2*(yLims(2)/2)], 'LineWidth', 0.5, 'Color', [0,0,0]);
line(-[preEventMs preEventMs - 100], [-0.05*lims(2), -0.05*lims(2)], 'LineWidth', 0.5, 'Color', [0,0,0]);

end

function [traces, tRaw] = computeLockedTraces(R, M, roi, dataField, eventTimeField, preMs, postMs, timeBase, smooth)

tRaw = (-preMs:timeBase:postMs)';

data = eventLockDataSmooth(R, M, eventTimeField, tRaw, smooth, roi, dataField);
traces = [data.data];

end

function lims = plotPSTHSection(traces, clusters, uClusters, tOff, tRaw, scale, lims, lineWidth, semLineWidth, showTrials, errorBars, cmap, cmapLight)

nClusters = length(uClusters);

means = NaN(size(traces, 1), nClusters);
sems = NaN(size(traces, 1), nClusters);

for c = 1:nClusters
    thisClust = (clusters == uClusters(c));
    
    means(:, c) = scale * nanmean(traces(:, thisClust), 2);
    sems(:, c) = scale * nanstd(traces(:, thisClust), 0, 2) / sqrt(sum(thisClust));
end

% Find min/max
lims = double([min([lims(1); means(:) - sems(:); lims(2)]) max([lims(1); means(:) + sems(:); lims(2)])]);

% Individual trials
if showTrials
    for c = 1:nClusters
        thisClust = (clusters == uClusters(c));
        
        if any(thisClust)
            line(tOff + tRaw, scale * traces(:, thisClust), 'Color', [cmap(c, :), 0.5], 'LineWidth', semLineWidth);
        end
    end
end

% Error bar traces
if strcmp(errorBars, 'traces')
    for c = 1:nClusters
        plot(tOff + tRaw, means(:, c) - sems(:, c), 'color', cmap(c, :), 'LineWidth', semLineWidth);
        plot(tOff + tRaw, means(:, c) + sems(:, c), 'color', cmap(c, :), 'LineWidth', semLineWidth);
    end
    
    % ... or error fills
elseif strcmp(errorBars, 'fills')
    for c = 1:nClusters
        fill(tOff + [tRaw; flipud(tRaw)], ...
            [means(:, c) - sems(:, c); flipud(means(:, c) + sems(:, c))], ...
            cmapLight(c, :), 'LineStyle', 'none');
    end
end

% Main traces
for c = 1:nClusters
    plot(tOff + tRaw, means(:, c), 'color', cmap(c, :), 'LineWidth', lineWidth);
end

end

function YData = plotRasterSection(locked, sortVals, clusters, uClusters, cmapClus, tOff, preMs, postMs, yLims)
yOffset = 0.07*yLims(2);

trialsAll = [];
clusVals = [];
for c = 1:length(uClusters)
    clus = uClusters(c);
    if ~isempty(sortVals)
        sortValsClus = sortVals(clusters == clus);
    else
        means = nanmean(locked(:, clusters==clus), 2);
        [~, maxBin] = max(means);
        sortValsClus = locked(maxBin,clusters==clus);
    end
    [~, sortedTrials] = sort(sortValsClus); % default is ascending
    clusTrs = locked(:,clusters==clus);
    clusTrs = clusTrs(:, sortedTrials);
    trialsAll = [trialsAll, clusTrs];
    clusVals = [clusVals; clus*ones(size(clusTrs,2),1)];
end
trialsAll = trialsAll';

XData = [tOff + -preMs,  tOff + postMs];
YData = [yLims(2) + yLims(2) + yOffset, yLims(2) + yOffset];
imagesc('CData', trialsAll, 'XData', XData, 'YData', YData);
colormap('hot');
% xticks([1, find(tPts == 0), length(tPts)]);
% xticklabels(cellstr(string(tPts([1, find(tPts == 0), length(tPts)]))));

nTrials = size(trialsAll,1);
pxlYCoords = linspace(yLims(2) + yLims(2) + yOffset, yLims(2) + yOffset, nTrials);

for c = 1:length(uClusters)
    clus = uClusters(c);
    pxlYCoordsClus = pxlYCoords(clusVals == clus);
    % pxlYCoordsR = pxlYCoords(size(trialsL,2):end);
    xLblOffset = -30;
    line(xLblOffset + [XData(1), XData(1)], [pxlYCoordsClus(1) pxlYCoordsClus(end)], 'LineWidth', 2, 'Color', cmapClus(c,:));
    % line(xLblOffset + [tOff + -preMs, tOff + -preMs], [pxlYCoordsR(1) pxlYCoordsR(end)], 'LineWidth', 5, 'Color', [1,0,0]);
end

end

function horizAxis(tOff, preMs, postMs, lims, eventName)

% Water-locked
axParams.tickLocations = tOff + [-preMs 0 postMs];
axParams.tickLabelLocations = axParams.tickLocations;
axParams.tickLabels = {num2str(-preMs), eventName, num2str(postMs)};
axParams.axisOffset = -0.02*lims(2);
axParams.axisOffset = -0.035*lims(2);
axParams.fontSize = 8;
axParams.lineThickness = 0.5;
AxisMMC(axParams.tickLocations(1), axParams.tickLocations(end), axParams);

end