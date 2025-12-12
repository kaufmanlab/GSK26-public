%% Figure 2 main
YOURDATAPATH = '';

%% Get data for all panels
mouseInfoAll = {{'cfa17', '200825'}, ...
    {'cfa17', '200827'}, ...
    {'cfa19', '200820'}, ...
    {'cfa19', '200826'}, ...
    {'cfa20', '201114'}, ...
    {'cfa20', '201118'}, ...
    {'cfa22', '220605'}, ...
    {'cfa22', '220611'}, ...
    {'cfa24', '220724'}, ...
    {'cfa24', '220727'}};

% Get kinematics for all datasets, this will take a few minutes
kinematics = loadMultilockKinematicsAll(mouseInfoAll, YOURDATAPATH);

%% Get plotting parameters
mouse = 'cfa20';
session = '201114';
[~, M, ~] = loadData(mouse, session, 'R', 'DLC3', YOURDATAPATH);

%% Panel A:
% Skeleton with aperture polygon on top, from mouse 3
mouse = 'cfa20';
session = '201114';
trial = find(arrayfun(@(x) strcmp(x.animalID, mouse), kinematics) & arrayfun(@(x) contains(x.date, session), kinematics) & [kinematics.trialNumber] == 397);

% Params
M.plotParams.markers2Plot = 1:15;
M.plotParams.skeleton2Plot = [M.skeleton(1:17,:); [13,2]; [13,3]];
M.plotParams.markerSizes = [10, 10, 10, 10, 14, 14, 14, 14, 18, 18, 18, 18, 26, 36, 48]/2;
M.plotParams.linkColors = repmat([0.85, 0.85, 0.85], length(M.plotParams.skeleton2Plot),1);
M.plotParams.fillColor = [248, 147, 83]/255;
M.plotParams.fillAlpha = 0.5;
M.plotParams.markers2Fill = [1:4 13];
M.plotParams.markerColors = repmat([0.35,0.35,0.35], length(M.plotParams.markers2Plot), 1);

% Plot
plotAperturePolygon(kinematics(trial), M.plotParams)

%% Panel B:
% Time series of aperture and z velocity
plotApertureTimeSeries(kinematics(trial))

%% Panel C:
% Aperture event timing distributions
plotApertureEventHists(kinematics)

%% Panel D:
% Centroid trajectories with aperture events annotated
mouse = 'cfa20';
session = '201114';
trials = find(arrayfun(@(x) strcmp(x.animalID, mouse), kinematics) & arrayfun(@(x) contains(x.date, session), kinematics));
plotTrajectoryApertureEvents(kinematics(trials))

%% Panel E:
% Aperture time series spreads, locked to max Z velocity
plotApertureSpreads(kinematics)