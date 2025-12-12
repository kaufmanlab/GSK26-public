%% Figure 1 main
YOURDATAPATH = '';

%% Panels A-C use mouse 1
mouse = 'cfa17';
session = '200825';
[R, M, config] = loadData(mouse, session, 'R', 'DLC3', YOURDATAPATH);

% Lock data for trajectories
config.preT = -100;
config.postT = 100;
config.tBase = 10;
eventNames = {'liftTimeDLC', 'grabTimeC'};
goodTrials = ~isnan([R.(eventNames{1})]) & ~isnan([R.(eventNames{2})]) & [R.success] & ~isnan([R.grabTimeC]) & [R.liftRT] < 500 & [R.goodDLC] == 1 & [R.wrongZoneFirst] == 0 & [R.movementTime] < 500 & [R.timeToContact] < 1000;
kinematics = multiEventLockKinematics(R(goodTrials), M, eventNames, config.preT, config.postT, config.tBase, 0);

%% Panel A:
% Raw camera footage image with DLC labels

%% Panel B:
% Task timeline and paired snapshots of kinematic skeletons

% Get data
trial = 2;
tPts = [1, 49, 62, 70, 300];
posXYZ = R(trial).posXYZ(tPts,:,:);
% Plotting params
prox_cmap = repmat([215, 15, 175]/255, 3,1);
dist_cmap = repmat([255, 160, 25]/255, 12,1);
M.plotParams.markers2Plot = 1:15;
M.plotParams.skeleton2Plot = M.skeleton(1:17,:);
M.plotParams.markerSizes = [6, 6, 6, 6, 10, 10, 10, 10, 12, 12, 12, 12, 18, 24, 32];
M.plotParams.markerColors = [dist_cmap;prox_cmap];
M.plotParams.linkColors = repmat([0.85, 0.85, 0.85], 17,1);
view = [-17, 7];
% Plot
plotSkeleton(posXYZ, M.plotParams, view);

%% Panel C:
% Single trial reach trajectories

% Plotting params
M.plotParams.traceAlpha = 1;
M.plotParams.traceLineWidth = 0.2;
% Plot
plotTrajectories(kinematics, M.plotParams)

%% Get data for Panels D,E,F,G:
mouseInfo = {{'cfa17', '200825', '200827'}, ...
    {'cfa19', '200820', '200826'}, ...
    {'cfa20', '201114', '201118'}, ...
    {'cfa22', '220605', '220611'}, ...
    {'cfa24', '220724', '220727'}};
% Load all event times, this will take a few minutes
eventInfo = loadEventTimes(mouseInfo, YOURDATAPATH);

%% Panel D:
% Lift reaction times
plotEventTimeDistributions(eventInfo, 'liftRT', [-55, 500], 'cue')

%% Panel E:
% Time between lift and nearing spout
plotEventTimeDistributions(eventInfo, 'lift2ZoneTimes', [-55, 1000], 'lift')

%% Panel F:
% Movement time
plotEventTimeDistributions(eventInfo, 'lift2ContactTimes', [-55, 1000], 'lift')

%% Panel G:
% Number of spout contacts within 1s of cue
plotNContactsDistributions(eventInfo)

%% Get data for panel H:
load([YOURDATAPATH '/optoData.mat'])

%% Panel H:
% Histogram of contact times during optogenetic inactivation of M1
plotOptoHists(optoData)

%% Get data for panel I:
mouse = 'cfaVG1';
session = '210305';
[R, M, config] = loadData(mouse, session, 'R', 'DLC3', YOURDATAPATH);
% Lock the kinematics
config.preT = -100;
config.postT = 1000;
config.tBase = 10;
config.smoothSD = 35;
config.tPts = config.preT:config.tBase:config.postT;
eventName = 'liftTimeDLC';
kinematics = eventLockKinematics(R([R.success] & ~isnan([R.grabTimeC]) & [R.wrongGrabFirst] == 0 & [R.goodDLC] == 1), M, eventName, config.tPts, 'smoothMethod', 'Gaussian', 'gaussSD', 15);
for trial = 1:length(kinematics)
    kinematics(trial).optoTrial = R(kinematics(trial).trialNumber).optoTrial;
end

%% Panel I:
% Finger tip trajectories from a single session of inactivations
plotOptoTrajectories(kinematics, M.plotParams);