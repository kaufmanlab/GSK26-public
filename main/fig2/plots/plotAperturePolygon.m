function plotAperturePolygon(data, plotParams)
% Plots the skeleton for a specific set of time points, with the aperture
% polygon filled in across the paw

% Configure params
liftBin = find(data.tPts == 0);
tPts = [liftBin, data.collectBin, data.extendBin]; % for figure, using these timepoints

% Create figure
fig;
hA = gca;
hold on;
hA.View = [-48, 8];
axis(hA, 'equal');
hA.ZLim = [-15, 20];
hA.XLim = [-25, 15];
hA.YLim = [80, 120];
title(num2str(data.trialNumber))

% First
drawSkeleton(hA, data.posXYZ(tPts(1),:,:), plotParams);
drawMarkers(hA, data.posXYZ(tPts(1),:,:), plotParams);
drawFill(hA, data.posXYZ(tPts(1),:,:), plotParams);

% Second time point
drawSkeleton(hA, data.posXYZ(tPts(2),:,:), plotParams);
drawMarkers(hA, data.posXYZ(tPts(2),:,:), plotParams);
drawFill(hA, data.posXYZ(tPts(2),:,:), plotParams);

% Last time point
drawSkeleton(hA, data.posXYZ(tPts(3),:,:), plotParams);
drawMarkers(hA, data.posXYZ(tPts(3),:,:), plotParams);
drawFill(hA, data.posXYZ(tPts(3),:,:), plotParams);
end