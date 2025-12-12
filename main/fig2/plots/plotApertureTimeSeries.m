function plotApertureTimeSeries(data)
% Plots the time series for a single trial of aperture and z velocity

% Params
liftCol = [130, 235, 118]/255;
collectCol = [72, 188, 255]/255;
extendCol = [230, 40, 151]/255;
aperturecol = [248, 147, 83]/255;
velocitycol = [0,0,0];
tPts = [-50:10:150];
bins = find(ismember(data.tPts, tPts));

fig;
hold on;
axis off

% Plot time series
velocity = data.CvelXYZ(bins,3);
velocitynorm = normalize(velocity, 'range', [0,1]);
plot(tPts, velocitynorm, 'Color', velocitycol, 'LineWidth', 2)

aperture = data.aperture(bins);
aperturenorm = normalize(aperture, 'range', [0,1]);
plot(tPts, aperturenorm, 'Color', aperturecol, 'LineWidth', 2)

[~, maxZSpeedBin] = max(velocitynorm);
line([tPts(maxZSpeedBin) tPts(maxZSpeedBin)], [0,1], 'Color', [0,0,0, 0.5], 'LineWidth', 1.5, 'LineStyle', '--');

% Lift
line([0, 0], [0 1], 'Color', [liftCol 0.5], 'LineWidth', 1.5, 'LineStyle', '--');

% Collect
collectBin = data.collectBin;
collectTime = data.tPts(collectBin);
line([collectTime, collectTime], [0, 1], 'Color', [collectCol 0.5], 'LineWidth', 1.5, 'LineStyle', '--');

% Extend
extendBin = data.extendBin;
extendTime = data.tPts(extendBin);
line([extendTime, extendTime], [0, 1], 'Color', [extendCol 0.5], 'LineWidth', 1.5, 'LineStyle', '--');


% Time axis
clear axParams
axParams.axisOrientation = 'h';
axParams.tickLocations = [tPts(1), 0, tPts(end)];
axParams.tickLabels = {num2str(tPts(1)), '0', num2str(tPts(end))};
axParams.tickLabelLocations = [tPts(1), 0, tPts(end)];
axParams.axisOffset = -0.05;
axParams.fontSize = 12;
axParams.axisLabel = '';
AxisMMC(axParams.tickLocations(1), axParams.tickLocations(end), axParams);

% Aperture axis
clear axParams
axParams.axisOrientation = 'v';
axParams.tickLocations = [0, 1];
axParams.tickLabels = {num2str(round(min(aperture),1)),  num2str(round(max(aperture),1))};
axParams.tickLabelLocations = [0, 1];
axParams.axisLabel = 'aperture (au)';
axParams.axisOffset = -60;
axParams.fontSize = 12;
axParams.color = aperturecol;
AxisMMC(axParams.tickLocations(1), axParams.tickLocations(end), axParams);

% Z velocity axis
clear axParams
axParams.axisOrientation = 'v';
axParams.tickLocations = [0, 1];
axParams.tickLabels = {num2str(round(min(velocity),1)),  num2str(round(max(velocity),1))};
axParams.tickLabelLocations = [0, 1];
axParams.axisLabel = 'z velocity (mm/s)';
axParams.axisOffset = 160;
axParams.fontSize = 12;
axParams.color = velocitycol;
axParams.invert = 1;
AxisMMC(axParams.tickLocations(1), axParams.tickLocations(end), axParams);

end